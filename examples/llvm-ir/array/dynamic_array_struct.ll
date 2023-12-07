; ModuleID = 'StructArrayExample'
source_filename = "dynamic_array_struct"

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
  %0 = call ptr @heap_malloc(i64 14)
  %elemptr0 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 0
  %1 = call ptr @heap_malloc(i64 7)
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %1, i32 0, i32 0
  store i64 0, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %1, i32 0, i32 1
  store i64 111, ptr %struct_member1, align 4
  %struct_member2 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %1, i32 0, i32 2
  %2 = call ptr @heap_malloc(i64 5)
  %elemptr03 = getelementptr [5 x i64], ptr %2, i64 0
  store i64 1, ptr %elemptr03, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %2, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %2, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %2, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %2, i64 4
  store i64 5, ptr %elemptr4, align 4
  %elem = load [5 x i64], ptr %2, align 4
  store [5 x i64] %elem, ptr %struct_member2, align 4
  %elem4 = load { i64, i64, [5 x i64] }, ptr %1, align 4
  store { i64, i64, [5 x i64] } %elem4, ptr %elemptr0, align 4
  %elemptr15 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 1
  %3 = call ptr @heap_malloc(i64 7)
  %struct_member6 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %3, i32 0, i32 0
  store i64 0, ptr %struct_member6, align 4
  %struct_member7 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %3, i32 0, i32 1
  store i64 0, ptr %struct_member7, align 4
  %struct_member8 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %3, i32 0, i32 2
  %4 = call ptr @heap_malloc(i64 5)
  %elemptr09 = getelementptr [5 x i64], ptr %4, i64 0
  store i64 0, ptr %elemptr09, align 4
  %elemptr110 = getelementptr [5 x i64], ptr %4, i64 1
  store i64 0, ptr %elemptr110, align 4
  %elemptr211 = getelementptr [5 x i64], ptr %4, i64 2
  store i64 0, ptr %elemptr211, align 4
  %elemptr312 = getelementptr [5 x i64], ptr %4, i64 3
  store i64 0, ptr %elemptr312, align 4
  %elemptr413 = getelementptr [5 x i64], ptr %4, i64 4
  store i64 0, ptr %elemptr413, align 4
  %elem14 = load [5 x i64], ptr %4, align 4
  store [5 x i64] %elem14, ptr %struct_member8, align 4
  %elem15 = load { i64, i64, [5 x i64] }, ptr %3, align 4
  store { i64, i64, [5 x i64] } %elem15, ptr %elemptr15, align 4
  ret ptr %0
}

define i64 @getFirstBookID(ptr %0) {
entry:
  %_books = alloca ptr, align 8
  store ptr %0, ptr %_books, align 8
  %1 = load ptr, ptr %_books, align 8
  call void @builtin_range_check(i64 1)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %1, i64 0
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  call void @builtin_range_check(i64 3)
  %index_access1 = getelementptr [5 x i64], ptr %struct_member, i64 1
  %2 = load i64, ptr %index_access1, align 4
  ret i64 %2
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %size_var25 = alloca i64, align 8
  %size_var = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 4273215651, label %func_0_dispatch
    i64 4248376571, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  store i64 0, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %4 = icmp ult i64 %index, 2
  br i1 %4, label %body, label %end_for

next:                                             ; preds = %body
  %index1 = load i64, ptr %index_ptr, align 4
  %5 = add i64 %index1, 1
  store i64 %5, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %6 = sub i64 1, %index
  call void @builtin_range_check(i64 %6)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 %index
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  %7 = load i64, ptr %size_var, align 4
  %8 = add i64 %7, 7
  store i64 %8, ptr %size_var, align 4
  br label %next

end_for:                                          ; preds = %cond
  %9 = load i64, ptr %size_var, align 4
  %heap_size = add i64 %9, 1
  %10 = call ptr @heap_malloc(i64 %heap_size)
  %offset_var_no = alloca i64, align 8
  store i64 0, ptr %offset_var_no, align 4
  %index_ptr2 = alloca i64, align 8
  store i64 0, ptr %index_ptr2, align 4
  %index3 = load i64, ptr %index_ptr2, align 4
  br label %cond4

cond4:                                            ; preds = %next5, %end_for
  %11 = icmp ult i64 %index3, 2
  br i1 %11, label %body6, label %end_for7

next5:                                            ; preds = %body6
  %index23 = load i64, ptr %index_ptr2, align 4
  %12 = add i64 %index23, 1
  store i64 %12, ptr %index_ptr2, align 4
  br label %cond4

body6:                                            ; preds = %cond4
  %13 = sub i64 1, %index3
  call void @builtin_range_check(i64 %13)
  %index_access8 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 %index3
  %14 = load i64, ptr %offset_var_no, align 4
  %struct_member9 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 0
  %elem = load i64, ptr %struct_member9, align 4
  %encode_value_ptr = getelementptr i64, ptr %10, i64 %14
  store i64 %elem, ptr %encode_value_ptr, align 4
  %15 = add i64 1, %14
  %struct_member10 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 1
  %elem11 = load i64, ptr %struct_member10, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %10, i64 %15
  store i64 %elem11, ptr %encode_value_ptr12, align 4
  %16 = add i64 1, %15
  %struct_member13 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 2
  %elemptr0 = getelementptr [5 x i64], ptr %struct_member13, i64 0, i64 0
  %17 = load i64, ptr %elemptr0, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %10, i64 %16
  store i64 %17, ptr %encode_value_ptr14, align 4
  %offset = add i64 %16, 1
  %elemptr1 = getelementptr [5 x i64], ptr %struct_member13, i64 0, i64 1
  %18 = load i64, ptr %elemptr1, align 4
  %encode_value_ptr15 = getelementptr i64, ptr %10, i64 %offset
  store i64 %18, ptr %encode_value_ptr15, align 4
  %offset16 = add i64 %offset, 1
  %elemptr2 = getelementptr [5 x i64], ptr %struct_member13, i64 0, i64 2
  %19 = load i64, ptr %elemptr2, align 4
  %encode_value_ptr17 = getelementptr i64, ptr %10, i64 %offset16
  store i64 %19, ptr %encode_value_ptr17, align 4
  %offset18 = add i64 %offset16, 1
  %elemptr3 = getelementptr [5 x i64], ptr %struct_member13, i64 0, i64 3
  %20 = load i64, ptr %elemptr3, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %10, i64 %offset18
  store i64 %20, ptr %encode_value_ptr19, align 4
  %offset20 = add i64 %offset18, 1
  %elemptr4 = getelementptr [5 x i64], ptr %struct_member13, i64 0, i64 4
  %21 = load i64, ptr %elemptr4, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %10, i64 %offset20
  store i64 %21, ptr %encode_value_ptr21, align 4
  %offset22 = add i64 %offset20, 1
  %22 = add i64 %14, 7
  store i64 %22, ptr %offset_var_no, align 4
  br label %next5

end_for7:                                         ; preds = %cond4
  %23 = load i64, ptr %offset_var_no, align 4
  %24 = sub i64 %23, 0
  %25 = add i64 %24, 0
  %encode_value_ptr24 = getelementptr i64, ptr %10, i64 %25
  store i64 %9, ptr %encode_value_ptr24, align 4
  call void @set_tape_data(ptr %10, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  store i64 0, ptr %size_var25, align 4
  %index_ptr26 = alloca i64, align 8
  store i64 0, ptr %index_ptr26, align 4
  %index27 = load i64, ptr %index_ptr26, align 4
  br label %cond28

cond28:                                           ; preds = %next29, %func_1_dispatch
  %26 = icmp ult i64 %index27, 2
  br i1 %26, label %body30, label %end_for31

next29:                                           ; preds = %body30
  %index34 = load i64, ptr %index_ptr26, align 4
  %27 = add i64 %index34, 1
  store i64 %27, ptr %index_ptr26, align 4
  br label %cond28

body30:                                           ; preds = %cond28
  %28 = sub i64 1, %index27
  call void @builtin_range_check(i64 %28)
  %index_access32 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %input, i64 %index27
  %struct_member33 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access32, i32 0, i32 2
  %29 = load i64, ptr %size_var25, align 4
  %30 = add i64 %29, 7
  store i64 %30, ptr %size_var25, align 4
  br label %next29

end_for31:                                        ; preds = %cond28
  %31 = load i64, ptr %size_var25, align 4
  %32 = getelementptr ptr, ptr %input, i64 %31
  %33 = call i64 @getFirstBookID(ptr %input)
  %34 = call ptr @heap_malloc(i64 2)
  %encode_value_ptr35 = getelementptr i64, ptr %34, i64 0
  store i64 %33, ptr %encode_value_ptr35, align 4
  %encode_value_ptr36 = getelementptr i64, ptr %34, i64 1
  store i64 1, ptr %encode_value_ptr36, align 4
  call void @set_tape_data(ptr %34, i64 2)
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
