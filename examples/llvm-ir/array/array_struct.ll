; ModuleID = 'StructArrayExample'
source_filename = "array_struct"

@heap_address = internal global i64 -12884901885

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare void @get_context_data(ptr, i64)

declare void @get_tape_data(ptr, i64)

declare void @set_tape_data(ptr, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define ptr @heap_malloc(i64 %0) {
entry:
  %size_alloca = alloca i64, align 8
  store i64 %0, ptr %size_alloca, align 4
  %size = load i64, ptr %size_alloca, align 4
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %size
  store i64 %updated_address, ptr @heap_address, align 4
  %1 = inttoptr i64 %current_address to ptr
  ret ptr %1
}

define ptr @vector_new(i64 %0) {
entry:
  %size_alloca = alloca i64, align 8
  store i64 %0, ptr %size_alloca, align 4
  %size = load i64, ptr %size_alloca, align 4
  %1 = add i64 %size, 1
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %1
  store i64 %updated_address, ptr @heap_address, align 4
  %2 = inttoptr i64 %current_address to ptr
  store i64 %size, ptr %2, align 4
  ret ptr %2
}

define void @memcpy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

define i64 @memcmp_eq(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp ugt i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define void @u32_div_mod(i64 %0, i64 %1, ptr %2, ptr %3) {
entry:
  %remainder_alloca = alloca ptr, align 8
  %quotient_alloca = alloca ptr, align 8
  %divisor_alloca = alloca i64, align 8
  %dividend_alloca = alloca i64, align 8
  store i64 %0, ptr %dividend_alloca, align 4
  %dividend = load i64, ptr %dividend_alloca, align 4
  store i64 %1, ptr %divisor_alloca, align 4
  %divisor = load i64, ptr %divisor_alloca, align 4
  store ptr %2, ptr %quotient_alloca, align 8
  %quotient = load ptr, ptr %quotient_alloca, align 8
  store ptr %3, ptr %remainder_alloca, align 8
  %remainder = load ptr, ptr %remainder_alloca, align 8
  %4 = call i64 @prophet_u32_mod(i64 %dividend, i64 %divisor)
  call void @builtin_range_check(i64 %4)
  %5 = add i64 %4, 1
  %6 = sub i64 %divisor, %5
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @prophet_u32_div(i64 %dividend, i64 %divisor)
  call void @builtin_range_check(ptr %quotient)
  %8 = mul i64 %7, %divisor
  %9 = add i64 %8, %4
  %10 = icmp eq i64 %9, %dividend
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 %7, ptr %quotient, align 4
  store i64 %4, ptr %remainder, align 4
  ret void
}

define i64 @u32_power(i64 %0, i64 %1) {
entry:
  %exponent_alloca = alloca i64, align 8
  %base_alloca = alloca i64, align 8
  store i64 %0, ptr %base_alloca, align 4
  %base = load i64, ptr %base_alloca, align 4
  store i64 %1, ptr %exponent_alloca, align 4
  %exponent = load i64, ptr %exponent_alloca, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = phi i64 [ 0, %entry ], [ %inc, %loop ]
  %3 = phi i64 [ 1, %entry ], [ %multmp, %loop ]
  %inc = add i64 %2, 1
  %multmp = mul i64 %3, %base
  %loopcond = icmp ule i64 %inc, %exponent
  br i1 %loopcond, label %loop, label %exit

exit:                                             ; preds = %loop
  call void @builtin_range_check(i64 %3)
  ret i64 %3
}

define ptr @createBooks() {
entry:
  %index_alloca = alloca i64, align 8
  %0 = call ptr @vector_new(i64 1)
  %vector_data = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 1
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %1 = call ptr @heap_malloc(i64 2)
  store ptr %1, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_length = load i64, ptr %0, align 4
  %2 = sub i64 %vector_length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %vector_data1 = getelementptr i64, ptr %0, i64 1
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %4 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %4, i32 0, i32 0
  store i64 99, ptr %struct_member, align 4
  %struct_member3 = getelementptr inbounds { i64, i64 }, ptr %4, i32 0, i32 1
  store i64 100, ptr %struct_member3, align 4
  %5 = load ptr, ptr %4, align 8
  store ptr %5, ptr %index_access2, align 8
  ret ptr %0
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 4273215651, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  %vector_length = load i64, ptr %3, align 4
  %4 = mul i64 %vector_length, 2
  %5 = add i64 %4, 1
  %heap_size = add i64 %5, 1
  %6 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length1 = load i64, ptr %3, align 4
  %encode_value_ptr = getelementptr i64, ptr %6, i64 0
  store i64 %vector_length1, ptr %encode_value_ptr, align 4
  store i64 1, ptr %offset_ptr, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_0_dispatch
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %3, i64 %index
  %elem = load ptr, ptr %element, align 8
  %offset = load i64, ptr %offset_ptr, align 4
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %elem, i32 0, i32 0
  %elem2 = load i64, ptr %struct_member, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %6, i64 %offset
  store i64 %elem2, ptr %encode_value_ptr3, align 4
  %7 = add i64 1, %offset
  %struct_member4 = getelementptr inbounds { i64, i64 }, ptr %elem, i32 0, i32 1
  %elem5 = load i64, ptr %struct_member4, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %6, i64 %7
  store i64 %elem5, ptr %encode_value_ptr6, align 4
  %next_offset = add i64 2, %offset
  store i64 %next_offset, ptr %offset_ptr, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %vector_length1
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %8 = add i64 %vector_length1, 1
  %9 = add i64 %8, 0
  %encode_value_ptr7 = getelementptr i64, ptr %6, i64 %9
  store i64 %5, ptr %encode_value_ptr7, align 4
  call void @set_tape_data(ptr %6, i64 %heap_size)
  ret void
}

define void @main() {
entry:
  %0 = call ptr @heap_malloc(i64 13)
  call void @get_tape_data(ptr %0, i64 13)
  %function_selector = load i64, ptr %0, align 4
  %1 = call ptr @heap_malloc(i64 14)
  call void @get_tape_data(ptr %1, i64 14)
  %input_length = load i64, ptr %1, align 4
  %2 = add i64 %input_length, 14
  %3 = call ptr @heap_malloc(i64 %2)
  call void @get_tape_data(ptr %3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %3)
  ret void
}
