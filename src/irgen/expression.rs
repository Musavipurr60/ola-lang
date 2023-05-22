use crate::irgen::array_boundary::handle_array_assign;
use crate::irgen::binary::Binary;
use crate::irgen::functions::FunctionContext;
use crate::irgen::u32_op::{
    u32_add, u32_and, u32_bitwise_and, u32_bitwise_not, u32_bitwise_or, u32_bitwise_xor, u32_div,
    u32_equal, u32_less, u32_less_equal, u32_mod, u32_more, u32_more_equal, u32_mul, u32_not,
    u32_not_equal, u32_or, u32_power, u32_shift_left, u32_shift_right, u32_sub,
};
use crate::irgen::unused_variable::should_remove_assignment;
use crate::sema::ast::{ArrayLength, Expression, Function, LibFunc, Namespace, RetrieveType, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::expression::{bigint_to_expression, ResolveTo};
use inkwell::types::{BasicType, BasicTypeEnum};
use inkwell::values::{
    AnyValue, BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue,
};
use inkwell::AddressSpace;
use num_bigint::BigInt;
use num_traits::ToPrimitive;
use ola_parser::program;

pub fn expression<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match expr {
        Expression::Add(_, _, l, r) => u32_add(l, r, bin, func_context, ns),
        Expression::Subtract(_, _, l, r) => u32_sub(l, r, bin, func_context, ns),
        Expression::Multiply(_, _, l, r) => u32_mul(l, r, bin, func_context, ns),
        Expression::Divide(_, _, l, r) => u32_div(l, r, bin, func_context, ns),
        Expression::Modulo(_, _, l, r) => u32_mod(l, r, bin, func_context, ns),
        Expression::BitwiseOr(_, _, l, r) => u32_bitwise_or(l, r, bin, func_context, ns),
        Expression::BitwiseAnd(_, _, l, r) => u32_bitwise_and(l, r, bin, func_context, ns),
        Expression::BitwiseXor(_, _, l, r) => u32_bitwise_xor(l, r, bin, func_context, ns),
        Expression::ShiftLeft(_, _, l, r) => u32_shift_left(l, r, bin, func_context, ns),
        Expression::ShiftRight(_, _, l, r) => u32_shift_right(l, r, bin, func_context, ns),
        Expression::Equal(_, l, r) => u32_equal(l, r, bin, func_context, ns),
        Expression::NotEqual(_, l, r) => u32_not_equal(l, r, bin, func_context, ns),
        Expression::More(_, l, r) => u32_more(l, r, bin, func_context, ns),
        Expression::MoreEqual(_, l, r) => u32_more_equal(l, r, bin, func_context, ns),
        Expression::Less(_, l, r) => u32_less(l, r, bin, func_context, ns),
        Expression::LessEqual(_, l, r) => u32_less_equal(l, r, bin, func_context, ns),

        Expression::Not(_, expr) => u32_not(expr, bin, func_context, ns),
        Expression::BitwiseNot(_, _, expr) => u32_bitwise_not(expr, bin, func_context, ns),
        Expression::Or(_, l, r) => u32_or(l, r, bin, func_context, ns),
        Expression::And(_, l, r) => u32_and(l, r, bin, func_context, ns),
        Expression::Power(_, _, l, r) => u32_power(l, r, bin, func_context, ns),
        // TODO refactor Decrement and Increment
        Expression::Decrement(_, _, expr) => match expr.as_ref() {
            Expression::Variable(_, ty, pos) => {
                let one = bin.context.i64_type().const_int(1, false);
                let before_ptr = *func_context.var_table.get(pos).unwrap();
                let before_val = bin.builder.build_load(
                    bin.llvm_type(&ty, ns),
                    before_ptr.into_pointer_value(),
                    "",
                );
                before_val
                    .as_instruction_value()
                    .unwrap()
                    .set_alignment(8)
                    .unwrap();
                let after = bin.builder.build_int_sub(
                    before_val.as_any_value_enum().into_int_value(),
                    one,
                    "",
                );
                bin.builder
                    .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum())
                    .set_alignment(8)
                    .unwrap();
                return before_ptr.as_basic_value_enum();
            }
            _ => unreachable!(),
        },
        Expression::Increment(_, _, expr) => match expr.as_ref() {
            Expression::Variable(_, ty, pos) => {
                let one = bin.context.i64_type().const_int(1, false);
                let before_ptr = *func_context.var_table.get(pos).unwrap();
                let before_val = bin.builder.build_load(
                    bin.llvm_type(&ty, ns),
                    before_ptr.into_pointer_value(),
                    "",
                );
                before_val
                    .as_instruction_value()
                    .unwrap()
                    .set_alignment(8)
                    .unwrap();
                let after = bin
                    .builder
                    .build_int_add(before_val.into_int_value(), one, "");
                bin.builder
                    .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum())
                    .set_alignment(8)
                    .unwrap();
                return before_ptr.as_basic_value_enum();
            }
            _ => unreachable!(),
        },
        Expression::Assign(_, _, l, r) => {
            let right_value = expression(r, bin, func_context, ns);

            // If an assignment where the left hand side is an array, call a helper
            // function that updates the temp variable.
            if let Expression::Variable(_, Type::Array(..), var_no, ..) = &**l {
                handle_array_assign(r, bin, func_context, *var_no, ns);
            }
            assign_single(l, right_value, bin, func_context, ns)
        }
        Expression::FunctionCall { .. } => {
            let (ret, _) = emit_function_call(expr, bin, func_context, ns);
            ret
        }
        Expression::NumberLiteral(_, ty, n) => bin.number_literal(ty, n, ns).into(),

        Expression::Variable(_, ty, var_no) => {
            let ptr = func_context
                .var_table
                .get(var_no)
                .unwrap()
                .as_basic_value_enum();
            if ty.is_reference_type(ns) {
                return ptr;
            }
            let load_var =
                bin.builder
                    .build_load(bin.llvm_type(&ty, ns), ptr.into_pointer_value(), "");
            load_var
                .as_instruction_value()
                .unwrap()
                .set_alignment(8)
                .unwrap();
            load_var
        }

        Expression::LibFunction(_, _, LibFunc::U32Sqrt, args) => {
            let value = expression(&args[0], bin, func_context, ns).into_int_value();
            let root = bin
                .builder
                .build_call(
                    bin.module
                        .get_function("u32_sqrt")
                        .expect("u32_sqrt should have been defined before"),
                    &[value.into()],
                    "",
                )
                .try_as_basic_value()
                .left()
                .expect("Should have a left return value");
            root
        }

        Expression::StructLiteral(loc, ty, fields) => {
            let struct_ty = bin.llvm_type(ty, ns);

            let struct_alloca = bin.build_alloca(func_context.func_val, struct_ty, "struct_alloca");

            for (i, expr) in fields.iter().enumerate() {
                let elemptr = unsafe {
                    bin.builder.build_gep(
                        struct_ty,
                        struct_alloca,
                        &[
                            bin.context.i64_type().const_zero(),
                            bin.context.i64_type().const_int(i as u64, false),
                        ],
                        "struct member",
                    )
                };

                let elem = expression(expr, bin, func_context, ns);

                let elem = if expr.ty().is_fixed_reference_type() {
                    let load_type = bin.llvm_type(&expr.ty(), ns);
                    bin.builder
                        .build_load(load_type, elem.into_pointer_value(), "elem")
                } else {
                    elem
                };

                bin.builder.build_store(elemptr, elem);
            }

            struct_alloca.into()
        }

        Expression::ArrayLiteral(loc, ty, dimensions, values) => {
            let array_ty = bin.llvm_type(ty, ns);
            let array_alloca = bin.build_alloca(func_context.func_val, array_ty, "array_literal");

            for (i, expr) in values.iter().enumerate() {
                let mut ind = vec![bin.context.i64_type().const_zero()];

                let mut e = i as u32;

                // Mapping one-dimensional array indices to multi-dimensional array indices.
                for d in dimensions {
                    ind.insert(1, bin.context.i64_type().const_int((e % *d).into(), false));

                    e /= *d;
                }

                let elemptr = unsafe {
                    bin.builder
                        .build_gep(array_ty, array_alloca, &ind, &format!("elemptr{i}"))
                };

                let elem = expression(expr, bin, func_context, ns);

                let elem = if expr.ty().is_fixed_reference_type() {
                    bin.builder.build_load(
                        bin.llvm_type(&expr.ty(), ns),
                        elem.into_pointer_value(),
                        "elem",
                    )
                } else {
                    elem
                };

                bin.builder.build_store(elemptr, elem);
            }

            array_alloca.into()
        }
        Expression::ConstArrayLiteral(loc, ty, dimensions, values) => {
            unimplemented!()
        }

        Expression::ConstantVariable(_, _, Some(var_contract_no), var_no) => {
            unimplemented!()
        }

        Expression::StorageArrayLength {
            loc,
            ty,
            array,
            elem_ty,
        } => {
            unimplemented!()
        }
        Expression::Subscript(loc, elem_ty, array_ty, array, index) => {
            array_subscript(loc, elem_ty, array_ty, array, index, bin, func_context, ns)
        }
        Expression::StructMember(loc, ty, var, field_no) if ty.is_contract_storage() => {
            unimplemented!()
        }
        Expression::StructMember(loc, ty, var, member) => {
            let struct_ty = bin.llvm_type(expr.ty().deref_memory(), ns);
            let struct_ptr = expression(var, bin, func_context, ns).into_pointer_value();
            bin.builder
                .build_struct_gep(struct_ty, struct_ptr, *member as u32, "struct member")
                .unwrap()
                .into()
        }
        Expression::Load(loc, ty, expr) => {
            let ptr = expression(expr, bin, func_context, ns).into_pointer_value();
            if ty.is_reference_type(ns) && !ty.is_fixed_reference_type() {
                let loaded_type = bin.llvm_type(ty, ns).ptr_type(AddressSpace::default());
                let value = bin.builder.build_load(loaded_type, ptr, "");
                // if the pointer is null, it needs to be allocated
                let allocation_needed = bin
                    .builder
                    .build_is_null(value.into_pointer_value(), "allocation_needed");
                let allocate = bin
                    .context
                    .append_basic_block(func_context.func_val, "allocate");
                let already_allocated = bin
                    .context
                    .append_basic_block(func_context.func_val, "already_allocated");
                bin.builder.build_conditional_branch(
                    allocation_needed,
                    allocate,
                    already_allocated,
                );

                let entry = bin.builder.get_insert_block().unwrap();

                bin.builder.position_at_end(allocate);

                // allocate a new struct
                let ty = expr.ty();

                let llvm_ty = bin.llvm_type(ty.deref_memory(), ns);

                // TODO malloc a stack or heap struct?
                let new_struct = bin.build_alloca(func_context.func_val, llvm_ty, "struct_alloca");
                bin.builder.build_store(ptr, new_struct);
                bin.builder.build_unconditional_branch(already_allocated);
                bin.builder.position_at_end(already_allocated);
                let combined_struct_ptr = bin.builder.build_phi(
                    llvm_ty.ptr_type(AddressSpace::default()),
                    &format!("ptr_{}", ty.to_string(ns)),
                );
                combined_struct_ptr.add_incoming(&[(&value, entry), (&new_struct, allocate)]);

                combined_struct_ptr.as_basic_value()
            } else {
                let loaded_type = bin.llvm_type(ty, ns);
                bin.builder.build_load(loaded_type, ptr, "")
            }
        }

        Expression::LibFunction(loc, tys, LibFunc::ArrayPush, args) => {
            if args[0].ty().is_contract_storage() {
                // TODO Add support for storage type arrays
                unimplemented!();
            } else {
                // TODO Add memory array push support
                unimplemented!();
            }
        }
        Expression::LibFunction(loc, ty, LibFunc::ArrayPop, args) => {
            if args[0].ty().is_contract_storage() {
                // TODO Add support for storage type arrays
                unimplemented!();
            } else {
                // TODO Add memory array pop support
                unimplemented!();
            }
        }
        Expression::LibFunction(loc, ty, LibFunc::ArrayLength, args) => {
            let array = expression(&args[0], bin, func_context, ns);

            bin.vector_len(array).into()
        }
        Expression::LibFunction(loc, ty, LibFunc::ArraySort, args) => {
            let array = expression(&args[0], bin, func_context, ns);
            let array_length = expression(&args[1], bin, func_context, ns);

            let array_sorted = bin
                .builder
                .build_call(
                    bin.module
                        .get_function("prophet_u32_array_sort")
                        .expect("prophet_u32_array_sort should have been defined before"),
                    &[array.into(), array_length.into()],
                    "",
                )
                .try_as_basic_value()
                .left()
                .expect("Should have a left return value");
            array_sorted.into()
        }
        Expression::AllocDynamicArray {
            loc,
            ty,
            length: size,
            init,
        } => {
            let size = expression(size, bin, func_context, ns).into_int_value();
            bin.vector_new(size)
        }
        Expression::ConditionalOperator(loc, ty, cond, left, right) => {
            conditional_operator(bin, ty, cond, func_context, ns, left, right)
        }
        Expression::BoolLiteral(loc, value) => {
            unimplemented!()
        }

        Expression::GetRef(loc, ty, exp) => {
            unimplemented!()
        }
        Expression::StorageVariable(loc, _, var_contract_no, var_no) => {
            unimplemented!()
        }
        Expression::StorageLoad(loc, ty, expr) => {
            unimplemented!()
        }
        Expression::Cast { loc, to, expr }
            if matches!(to, Type::Array(..))
                && matches!(**expr, Expression::ArrayLiteral { .. }) =>
        {
            let array_literal = expression(expr, bin, func_context, ns);
            array_literal
        }

        _ => {
            unimplemented!()
        }
    }
}

pub fn emit_function_call<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, bool) {
    if let Expression::FunctionCall { function, args, .. } = expr {
        if let Expression::Function { function_no, .. } = function.as_ref() {
            let callee = &ns.functions[*function_no];
            let callee_value = bin.module.get_function(&callee.name).unwrap();
            let params = args
                .iter()
                .map(|a| expression(a, bin, func_context, ns).into())
                .collect::<Vec<BasicMetadataValueEnum>>();

            let ret_value = bin
                .builder
                .build_call(callee_value, &params, "")
                .try_as_basic_value()
                .left()
                .unwrap();
            if callee.returns.len() == 1 {
                let ret = &callee.returns[0];

                if ret.ty.is_reference_type(ns) {
                    let ret_ptr =
                        bin.build_alloca(func_context.func_val, bin.llvm_var_ty(&ret.ty, ns), "");

                    bin.builder.build_store(ret_ptr, ret_value);
                    (ret_ptr.into(), true)
                } else {
                    (ret_value, true)
                }
            } else {
                let struct_ty = bin
                    .context
                    .struct_type(
                        &callee
                            .returns
                            .iter()
                            .map(|f| bin.llvm_field_ty(&f.ty, ns))
                            .collect::<Vec<BasicTypeEnum>>(),
                        false,
                    )
                    .as_basic_type_enum();
                let ret_ptr = bin.build_alloca(func_context.func_val, struct_ty, "struct_alloca");
                bin.builder.build_store(ret_ptr, ret_value);
                (ret_value, false)
            }
        } else {
            unimplemented!()
        }
    } else {
        unimplemented!()
    }
}

fn conditional_operator<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    cond: &Expression,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
    left: &Expression,
    right: &Expression,
) -> BasicValueEnum<'a> {
    let cond = expression(cond, bin, func_context, ns);
    let left_block = bin
        .context
        .append_basic_block(func_context.func_val, "left_value");
    let right_block = bin
        .context
        .append_basic_block(func_context.func_val, "right_value");
    let done_block = bin
        .context
        .append_basic_block(func_context.func_val, "conditional_done");

    bin.builder
        .build_conditional_branch(cond.into_int_value(), left_block, right_block);

    bin.builder.position_at_end(left_block);

    let left_val = expression(left, bin, func_context, ns);
    bin.builder.build_unconditional_branch(done_block);
    let left_block_end = bin.builder.get_insert_block().unwrap();
    bin.builder.position_at_end(right_block);

    let right_val = expression(right, bin, func_context, ns);
    bin.builder.build_unconditional_branch(done_block);

    let right_block_end = bin.builder.get_insert_block().unwrap();

    bin.builder.position_at_end(done_block);

    let phi = bin.builder.build_phi(bin.llvm_type(ty, ns), "phi");

    phi.add_incoming(&[(&left_val, left_block_end), (&right_val, right_block_end)]);

    phi.as_basic_value()
}

/// Codegen for an array subscript expression
fn array_subscript<'a>(
    loc: &program::Loc,
    elem_ty: &Type,
    array_ty: &Type,
    array: &Expression,
    index: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let array_ptr = expression(array, bin, func_context, ns);
    let index = expression(index, bin, func_context, ns);
    let array_length = match array_ty.deref_any() {
        Type::Array(..) => match array_ty.array_length() {
            None => {
                if let Type::StorageRef(..) = array_ty {
                    unimplemented!("storage array subscript")
                } else {
                    // If a subscript is encountered array length will be called
                    // Return array length by default
                    let array_length_expr = Expression::LibFunction(
                        *loc,
                        vec![Type::Uint(32)],
                        LibFunc::ArrayLength,
                        vec![array.clone()],
                    );
                    let mut returned = bin.context.i64_type().const_zero();
                    if let Expression::Variable(_, _, num) = &array {
                        // If the size is known, do the replacement
                        if let Some(array_length_var) = func_context.array_lengths_vars.get(num) {
                            returned = bin
                                .builder
                                .build_load(
                                    bin.context.i64_type(),
                                    array_length_var.into_pointer_value(),
                                    "array_length",
                                )
                                .into_int_value();
                        } else {
                            returned = expression(&array_length_expr, bin, func_context, ns)
                                .into_int_value();
                        }
                    }
                    returned.into()
                }
            }

            Some(l) => {
                let ast_big_int = bigint_to_expression(
                    loc,
                    l,
                    ns,
                    &mut Diagnostics::default(),
                    ResolveTo::Unknown,
                )
                .unwrap();
                expression(&ast_big_int, bin, func_context, ns)
            }
        },
        _ => {
            unreachable!()
        }
    };

    if array_ty.is_dynamic_memory() {
        return unsafe {
            bin.builder.build_gep(
                bin.context.i8_type(),
                bin.vector_bytes(array_ptr),
                &[index.into_int_value()],
                "index_access",
            )
        }
        .into();
    }
    let array_length_sub_one: BasicValueEnum = bin
        .builder
        .build_int_sub(
            array_length.into_int_value(),
            bin.context.i64_type().const_int(1, false),
            "",
        )
        .into();
    let array_length_sub_one_sub_index: BasicValueEnum = bin
        .builder
        .build_int_sub(
            array_length_sub_one.into_int_value(),
            index.into_int_value(),
            "",
        )
        .into();
    // check if index is out of bounds
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[array_length_sub_one_sub_index.into()],
        "",
    );

    // Create the gep (get element pointer) instruction to compute the pointer to
    // the desired element
    let array_type = bin.llvm_type(array_ty.deref_memory(), ns);
    let element_ptr = unsafe {
        bin.builder.build_gep(
            array_type,
            array_ptr.into_pointer_value(),
            &[bin.context.i64_type().const_zero(), index.into_int_value()],
            "index_access",
        )
    };

    element_ptr.as_basic_value_enum()
}

pub fn assign_single<'a>(
    left: &Expression,
    right_value: BasicValueEnum<'a>,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match left {
        Expression::Variable(loc, ty, var_no) => {
            let var_ptr = *func_context.var_table.get(var_no).unwrap();
            bin.builder
                .build_store(var_ptr.into_pointer_value(), right_value);
            var_ptr
        }
        _ => {
            let left_ty = left.ty();

            let dest = expression(left, bin, func_context, ns);

            match left_ty {
                Type::StorageRef(..) => {
                    unimplemented!()
                }
                Type::Ref(_) => {
                    bin.builder
                        .build_store(dest.into_pointer_value(), right_value);
                }
                _ => unreachable!(),
            }

            dest
        }
    }
}

// fn verify_sorted_array(
//     array: BasicValueEnum,
//     bin: &Binary,
//     func_context: &FunctionContext,
//     ns: &Namespace,
// ) {
//     let array_type = array.get_type();
//     let array_len = array_type.array_length();

//     let start_block = bin
//         .context
//         .append_basic_block(func_context.function, "start");
//     let loop_block = bin
//         .context
//         .append_basic_block(func_context.function, "loop");
//     let end_block = bin.context.append_basic_block(func_context.function,
// "end");

//     // Start block
//     bin.builder.position_at_end(start_block);
//     bin.builder.build_unconditional_branch(loop_block);

//     // Loop block
//     bin.builder.position_at_end(loop_block);

//     let index = bin.builder.build_phi(bin.context.i32_type(), "index");
//     index.add_incoming(&[(bin.context.i32_type().const_zero(),
// start_block)]);

//     let current_element_ptr = unsafe {
//         bin.builder.build_gep(
//             array.into_array_value(),
//             &[index.as_basic_value()],
//             "current_element_ptr",
//         )
//     };
//     let current_element = bin
//         .builder
//         .build_load(current_element_ptr, "current_element");

//     let next_index = bin.builder.build_int_add(
//         index.as_basic_value().into_int_value(),
//         bin.context.i32_type().const_int(1, false),
//         "next_index",
//     );
//     let next_element_ptr = unsafe {
//         bin.builder
//             .build_gep(array.into_array_value(), &[next_index],
// "next_element_ptr")     };
//     let next_element = bin.builder.build_load(next_element_ptr,
// "next_element");

//     let comparison = bin.builder.build_int_compare(
//         IntPredicate::ULE,
//         current_element.into_int_value(),
//         next_element.into_int_value(),
//         "comparison",
//     );

//     let continue_condition = bin.builder.build_int_compare(
//         IntPredicate::ULT,
//         next_index,
//         bin.context.i32_type().const_int(array_len as u64, false),
//         "continue_condition",
//     );
//     let is_sorted_condition =
//         bin.builder
//             .build_and(continue_condition, comparison,
// "is_sorted_condition");

//     index.add_incoming(&[(next_index, loop_block)]);

//     bin.builder
//         .build_conditional_branch(is_sorted_condition, loop_block,
// end_block);

//     // End block
//     bin.builder.position_at_end(end_block);
// }
