; ModuleID = 'DynamicTwoDimensionalArrayInMemory'
source_filename = "array_dynamic_2d"

@heap_address = internal global i64 -12884901885

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @builtin_check_ecdsa(ptr)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @prophet_split_field_high(i64)

declare i64 @prophet_split_field_low(i64)

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
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %0
  store i64 %updated_address, ptr @heap_address, align 4
  %1 = inttoptr i64 %current_address to ptr
  ret ptr %1
}

define ptr @vector_new(i64 %0) {
entry:
  %1 = add i64 %0, 1
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %1
  store i64 %updated_address, ptr @heap_address, align 4
  %2 = inttoptr i64 %current_address to ptr
  store i64 %0, ptr %2, align 4
  ret ptr %2
}

define void @split_field(i64 %0, ptr %1, ptr %2) {
entry:
  %3 = call i64 @prophet_split_field_high(i64 %0)
  call void @builtin_range_check(i64 %3)
  %4 = call i64 @prophet_split_field_low(i64 %0)
  call void @builtin_range_check(i64 %4)
  %5 = mul i64 %3, 4294967296
  %6 = add i64 %5, %4
  %7 = icmp eq i64 %0, %6
  %8 = zext i1 %7 to i64
  call void @builtin_assert(i64 %8)
  store i64 %3, ptr %1, align 4
  store i64 %4, ptr %2, align 4
  ret void
}

define void @memcpy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %0, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %1, i64 %index_value
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
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ne(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %right_elem, %left_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ult(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_ule(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %right_elem, %left_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %5, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %6, %4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 1, %low_compare_block ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @field_memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ule(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %5, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %6, %4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ult(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 1, %low_compare_block ], [ 0, %cond ]
  ret i64 %result_phi
}

define void @u32_div_mod(i64 %0, i64 %1, ptr %2, ptr %3) {
entry:
  %4 = call i64 @prophet_u32_mod(i64 %0, i64 %1)
  call void @builtin_range_check(i64 %4)
  %5 = add i64 %4, 1
  %6 = sub i64 %1, %5
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @prophet_u32_div(i64 %0, i64 %1)
  call void @builtin_range_check(ptr %2)
  %8 = mul i64 %7, %1
  %9 = add i64 %8, %4
  %10 = icmp eq i64 %9, %0
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 %7, ptr %2, align 4
  store i64 %4, ptr %3, align 4
  ret void
}

define i64 @u32_power(i64 %0, i64 %1) {
entry:
  %counter = alloca i64, align 8
  %result = alloca i64, align 8
  store i64 0, ptr %counter, align 4
  store i64 1, ptr %result, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = load i64, ptr %counter, align 4
  %3 = load i64, ptr %result, align 4
  %newCounter = add i64 %2, 1
  %newResult = mul i64 %3, %0
  store i64 %newCounter, ptr %counter, align 4
  store i64 %newResult, ptr %result, align 4
  %condition = icmp ult i64 %newCounter, %1
  br i1 %condition, label %loop, label %exit

exit:                                             ; preds = %loop
  %finalResult = load i64, ptr %result, align 4
  ret i64 %finalResult
}

define ptr @initialize(i64 %0, i64 %1) {
entry:
  %index_alloca = alloca i64, align 8
  %columns = alloca i64, align 8
  %rows = alloca i64, align 8
  store i64 %0, ptr %rows, align 4
  store i64 %1, ptr %columns, align 4
  %2 = load i64, ptr %rows, align 4
  %3 = call ptr @vector_new(i64 %2)
  %vector_data = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
<<<<<<< HEAD
  ret ptr %3
=======
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %4 = load i64, ptr %i, align 4
  %5 = load i64, ptr %rows, align 4
  %6 = icmp ult i64 %4, %5
  br i1 %6, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %7 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %3, align 4
  %8 = sub i64 %vector_length, 1
  %9 = sub i64 %8, %7
  call void @builtin_range_check(i64 %9)
  %vector_data3 = getelementptr i64, ptr %3, i64 1
  %index_access4 = getelementptr ptr, ptr %vector_data3, i64 %7
  %10 = load i64, ptr %columns, align 4
  %11 = call ptr @vector_new(i64 %10)
  %vector_data5 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %index_alloca9, align 4
  br label %cond6

next:                                             ; preds = %done8
  %12 = load i64, ptr %i, align 4
  %13 = add i64 %12, 1
  store i64 %13, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  ret ptr %3

cond6:                                            ; preds = %body7, %body2
  %index_value10 = load i64, ptr %index_alloca9, align 4
  %loop_cond11 = icmp ult i64 %index_value10, %10
  br i1 %loop_cond11, label %body7, label %done8

body7:                                            ; preds = %cond6
  %index_access12 = getelementptr ptr, ptr %vector_data5, i64 %index_value10
  store i64 0, ptr %index_access12, align 4
  %next_index13 = add i64 %index_value10, 1
  store i64 %next_index13, ptr %index_alloca9, align 4
  br label %cond6

done8:                                            ; preds = %cond6
  store ptr %11, ptr %index_access4, align 8
  br label %next
>>>>>>> 7998cf0 (fixed llvm type bug.)
}

define void @setElement(ptr %0, i64 %1, i64 %2, i64 %3) {
entry:
  %value = alloca i64, align 8
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %4 = load ptr, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  store i64 %3, ptr %value, align 4
  %5 = load i64, ptr %row, align 4
  %vector_length = load i64, ptr %4, align 4
  %6 = sub i64 %vector_length, 1
  %7 = sub i64 %6, %5
  call void @builtin_range_check(i64 %7)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %5
  %8 = load ptr, ptr %index_access, align 8
  %9 = load i64, ptr %column, align 4
  %vector_length1 = load i64, ptr %8, align 4
  %10 = sub i64 %vector_length1, 1
  %11 = sub i64 %10, %9
  call void @builtin_range_check(i64 %11)
  %vector_data2 = getelementptr i64, ptr %8, i64 1
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 %9
  %12 = load i64, ptr %value, align 4
  store i64 %12, ptr %index_access3, align 4
  ret void
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %3 = load ptr, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  %4 = load i64, ptr %row, align 4
  %vector_length = load i64, ptr %3, align 4
  %5 = sub i64 %vector_length, 1
  %6 = sub i64 %5, %4
  call void @builtin_range_check(i64 %6)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %4
  %7 = load ptr, ptr %index_access, align 8
  %8 = load i64, ptr %column, align 4
  %vector_length1 = load i64, ptr %7, align 4
  %9 = sub i64 %vector_length1, 1
  %10 = sub i64 %9, %8
  call void @builtin_range_check(i64 %10)
  %vector_data2 = getelementptr i64, ptr %7, i64 1
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 %8
  %11 = load i64, ptr %index_access3, align 4
  ret i64 %11
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
<<<<<<< HEAD
  %index_ptr106 = alloca i64, align 8
  %index_ptr93 = alloca i64, align 8
  %array_ptr91 = alloca ptr, align 8
  %offset_var90 = alloca i64, align 8
  %index_ptr67 = alloca i64, align 8
  %index_ptr55 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  %index_ptr32 = alloca i64, align 8
  %index_ptr20 = alloca i64, align 8
=======
  %index_ptr104 = alloca i64, align 8
  %index_ptr92 = alloca i64, align 8
  %array_ptr90 = alloca ptr, align 8
  %array_offset89 = alloca i64, align 8
  %index_ptr69 = alloca i64, align 8
  %index_ptr57 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  %index_ptr37 = alloca i64, align 8
  %index_ptr25 = alloca i64, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %buffer_offset = alloca i64, align 8
  %index_ptr4 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 1267704063, label %func_0_dispatch
    i64 399575402, label %func_1_dispatch
    i64 1503020561, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr ptr, ptr %3, i64 1
  %6 = load i64, ptr %5, align 4
  %7 = call ptr @initialize(i64 %4, i64 %6)
  store i64 0, ptr %array_size, align 4
  %vector_length = load i64, ptr %7, align 4
  %8 = load i64, ptr %array_size, align 4
  %9 = add i64 %8, %vector_length
  store i64 %9, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
<<<<<<< HEAD
  %vector_length = load i64, ptr %7, align 4
  %10 = load i64, ptr %index_ptr, align 4
  %11 = icmp ult i64 %10, %vector_length
  br i1 %11, label %body, label %end_for

body:                                             ; preds = %cond
  %12 = load i64, ptr %array_size, align 4
  %13 = add i64 %12, 1
  store i64 %13, ptr %array_size, align 4
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

next:                                             ; preds = %end_for5
  %index18 = load i64, ptr %index_ptr, align 4
  %14 = add i64 %index18, 1
  store i64 %14, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %15 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %15, 1
  %16 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %17 = load i64, ptr %buffer_offset, align 4
  %18 = add i64 %17, 1
  store i64 %18, ptr %buffer_offset, align 4
  %19 = getelementptr ptr, ptr %16, i64 %17
  %vector_length19 = load i64, ptr %7, align 4
  store i64 %vector_length19, ptr %19, align 4
  store i64 0, ptr %index_ptr20, align 4
  br label %cond21

cond2:                                            ; preds = %next4, %body
  %array_index = load i64, ptr %index_ptr, align 4
  %vector_length6 = load i64, ptr %7, align 4
  %20 = sub i64 %vector_length6, 1
  %21 = sub i64 %20, %array_index
  call void @builtin_range_check(i64 %21)
  %vector_data = getelementptr i64, ptr %7, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %vector_length7 = load i64, ptr %array_element, align 4
  %22 = load i64, ptr %index_ptr1, align 4
  %23 = icmp ult i64 %22, %vector_length7
  br i1 %23, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %array_index8 = load i64, ptr %index_ptr, align 4
  %vector_length9 = load i64, ptr %7, align 4
  %24 = sub i64 %vector_length9, 1
  %25 = sub i64 %24, %array_index8
  call void @builtin_range_check(i64 %25)
  %vector_data10 = getelementptr i64, ptr %7, i64 1
  %index_access11 = getelementptr ptr, ptr %vector_data10, i64 %array_index8
  %array_element12 = load ptr, ptr %index_access11, align 8
  %array_index13 = load i64, ptr %index_ptr1, align 4
  %vector_length14 = load i64, ptr %array_element12, align 4
  %26 = sub i64 %vector_length14, 1
  %27 = sub i64 %26, %array_index13
  call void @builtin_range_check(i64 %27)
  %vector_data15 = getelementptr i64, ptr %array_element12, i64 1
  %index_access16 = getelementptr i64, ptr %vector_data15, i64 %array_index13
  %array_element17 = load i64, ptr %index_access16, align 4
  %28 = load i64, ptr %array_size, align 4
  %29 = add i64 %28, 1
  store i64 %29, ptr %array_size, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index = load i64, ptr %index_ptr1, align 4
  %30 = add i64 %index, 1
  store i64 %30, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  br label %next

cond21:                                           ; preds = %next23, %end_for
  %vector_length25 = load i64, ptr %7, align 4
  %31 = load i64, ptr %index_ptr20, align 4
  %32 = icmp ult i64 %31, %vector_length25
  br i1 %32, label %body22, label %end_for24

body22:                                           ; preds = %cond21
  %array_index26 = load i64, ptr %index_ptr20, align 4
  %vector_length27 = load i64, ptr %7, align 4
  %33 = sub i64 %vector_length27, 1
  %34 = sub i64 %33, %array_index26
  call void @builtin_range_check(i64 %34)
  %vector_data28 = getelementptr i64, ptr %7, i64 1
  %index_access29 = getelementptr ptr, ptr %vector_data28, i64 %array_index26
  %array_element30 = load ptr, ptr %index_access29, align 8
  %35 = load i64, ptr %buffer_offset, align 4
  %36 = add i64 %35, 1
  store i64 %36, ptr %buffer_offset, align 4
  %37 = getelementptr ptr, ptr %16, i64 %35
  %vector_length31 = load i64, ptr %array_element30, align 4
  store i64 %vector_length31, ptr %37, align 4
  store i64 0, ptr %index_ptr32, align 4
  br label %cond33

next23:                                           ; preds = %end_for36
  %index54 = load i64, ptr %index_ptr20, align 4
  %38 = add i64 %index54, 1
  store i64 %38, ptr %index_ptr20, align 4
  br label %cond21

end_for24:                                        ; preds = %cond21
  %39 = load i64, ptr %buffer_offset, align 4
  %40 = getelementptr ptr, ptr %16, i64 %39
  store i64 %15, ptr %40, align 4
  call void @set_tape_data(ptr %16, i64 %heap_size)
  ret void

<<<<<<< HEAD
cond33:                                           ; preds = %next35, %body22
  %array_index37 = load i64, ptr %index_ptr20, align 4
  %vector_length38 = load i64, ptr %7, align 4
  %41 = sub i64 %vector_length38, 1
  %42 = sub i64 %41, %array_index37
  call void @builtin_range_check(i64 %42)
  %vector_data39 = getelementptr i64, ptr %7, i64 1
  %index_access40 = getelementptr i64, ptr %vector_data39, i64 %array_index37
  %array_element41 = load ptr, ptr %index_access40, align 8
  %vector_length42 = load i64, ptr %array_element41, align 4
  %43 = load i64, ptr %index_ptr32, align 4
  %44 = icmp ult i64 %43, %vector_length42
  br i1 %44, label %body34, label %end_for36
=======
cond33:                                           ; preds = %next34, %body23
  %vector_length37 = load i64, ptr %7, align 4
  %38 = sub i64 %vector_length37, 1
  %39 = sub i64 %38, %index20
  call void @builtin_range_check(i64 %39)
  %vector_data38 = getelementptr i64, ptr %7, i64 1
  %index_access39 = getelementptr i64, ptr %vector_data38, i64 %index20
  %arr40 = load ptr, ptr %index_access39, align 8
  %vector_length41 = load i64, ptr %arr40, align 4
  %40 = icmp ult i64 %index32, %vector_length41
  br i1 %40, label %body35, label %end_for36
>>>>>>> b61ab64 (fixed array decode and encode bugs.)

body34:                                           ; preds = %cond33
  %array_index43 = load i64, ptr %index_ptr20, align 4
  %vector_length44 = load i64, ptr %7, align 4
  %45 = sub i64 %vector_length44, 1
  %46 = sub i64 %45, %array_index43
  call void @builtin_range_check(i64 %46)
  %vector_data45 = getelementptr i64, ptr %7, i64 1
  %index_access46 = getelementptr i64, ptr %vector_data45, i64 %array_index43
  %array_element47 = load ptr, ptr %index_access46, align 8
  %array_index48 = load i64, ptr %index_ptr32, align 4
  %vector_length49 = load i64, ptr %array_element47, align 4
  %47 = sub i64 %vector_length49, 1
  %48 = sub i64 %47, %array_index48
  call void @builtin_range_check(i64 %48)
  %vector_data50 = getelementptr i64, ptr %array_element47, i64 1
  %index_access51 = getelementptr i64, ptr %vector_data50, i64 %array_index48
  %array_element52 = load i64, ptr %index_access51, align 4
  %49 = load i64, ptr %buffer_offset, align 4
  %50 = getelementptr ptr, ptr %16, i64 %49
  store i64 %array_element52, ptr %50, align 4
  %51 = load i64, ptr %buffer_offset, align 4
  %52 = add i64 %51, 1
  store i64 %52, ptr %buffer_offset, align 4
  br label %next35

next35:                                           ; preds = %body34
  %index53 = load i64, ptr %index_ptr32, align 4
  %53 = add i64 %index53, 1
  store i64 %53, ptr %index_ptr32, align 4
  br label %cond33

<<<<<<< HEAD
=======
body35:                                           ; preds = %cond33
  %vector_length42 = load i64, ptr %7, align 4
  %42 = sub i64 %vector_length42, 1
  %43 = sub i64 %42, %index20
  call void @builtin_range_check(i64 %43)
  %vector_data43 = getelementptr i64, ptr %7, i64 1
  %index_access44 = getelementptr i64, ptr %vector_data43, i64 %index20
  %arr45 = load ptr, ptr %index_access44, align 8
  %vector_length46 = load i64, ptr %arr45, align 4
  %44 = sub i64 %vector_length46, 1
  %45 = sub i64 %44, %index32
=======
  %vector_length1 = load i64, ptr %7, align 4
  %10 = icmp ult i64 %index, %vector_length1
  br i1 %10, label %body, label %end_for

next:                                             ; preds = %end_for9
  %index23 = load i64, ptr %index_ptr, align 4
  %11 = add i64 %index23, 1
  store i64 %11, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %vector_length2 = load i64, ptr %7, align 4
  %12 = sub i64 %vector_length2, 1
  %13 = sub i64 %12, %index
  call void @builtin_range_check(i64 %13)
  %vector_data = getelementptr i64, ptr %7, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %arr = load ptr, ptr %index_access, align 8
  %vector_length3 = load i64, ptr %arr, align 4
  %14 = load i64, ptr %array_size, align 4
  %15 = add i64 %14, %vector_length3
  store i64 %15, ptr %array_size, align 4
  store i64 0, ptr %index_ptr4, align 4
  %index5 = load i64, ptr %index_ptr4, align 4
  br label %cond6

end_for:                                          ; preds = %cond
  %16 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %16, 1
  %17 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %18 = load i64, ptr %buffer_offset, align 4
  %19 = add i64 %18, 1
  store i64 %19, ptr %buffer_offset, align 4
  %20 = getelementptr ptr, ptr %17, i64 %18
  %vector_length24 = load i64, ptr %7, align 4
  store i64 %vector_length24, ptr %20, align 4
  store i64 0, ptr %index_ptr25, align 4
  %index26 = load i64, ptr %index_ptr25, align 4
  br label %cond27

cond6:                                            ; preds = %next7, %body
  %vector_length10 = load i64, ptr %7, align 4
  %21 = sub i64 %vector_length10, 1
  %22 = sub i64 %21, %index
  call void @builtin_range_check(i64 %22)
  %vector_data11 = getelementptr i64, ptr %7, i64 1
  %index_access12 = getelementptr ptr, ptr %vector_data11, i64 %index
  %arr13 = load ptr, ptr %index_access12, align 8
  %vector_length14 = load i64, ptr %arr13, align 4
  %23 = icmp ult i64 %index5, %vector_length14
  br i1 %23, label %body8, label %end_for9

next7:                                            ; preds = %body8
  %index22 = load i64, ptr %index_ptr4, align 4
  %24 = add i64 %index22, 1
  store i64 %24, ptr %index_ptr4, align 4
  br label %cond6

body8:                                            ; preds = %cond6
  %vector_length15 = load i64, ptr %7, align 4
  %25 = sub i64 %vector_length15, 1
  %26 = sub i64 %25, %index
  call void @builtin_range_check(i64 %26)
  %vector_data16 = getelementptr i64, ptr %7, i64 1
  %index_access17 = getelementptr ptr, ptr %vector_data16, i64 %index
  %arr18 = load ptr, ptr %index_access17, align 8
  %vector_length19 = load i64, ptr %arr18, align 4
  %27 = sub i64 %vector_length19, 1
  %28 = sub i64 %27, %index5
  call void @builtin_range_check(i64 %28)
  %vector_data20 = getelementptr i64, ptr %arr18, i64 1
  %index_access21 = getelementptr i64, ptr %vector_data20, i64 %index5
  %29 = load i64, ptr %array_size, align 4
  %30 = add i64 %29, 1
  store i64 %30, ptr %array_size, align 4
  br label %next7

end_for9:                                         ; preds = %cond6
  br label %next

cond27:                                           ; preds = %next28, %end_for
  %vector_length31 = load i64, ptr %7, align 4
  %31 = icmp ult i64 %index26, %vector_length31
  br i1 %31, label %body29, label %end_for30

next28:                                           ; preds = %end_for42
  %index56 = load i64, ptr %index_ptr25, align 4
  %32 = add i64 %index56, 1
  store i64 %32, ptr %index_ptr25, align 4
  br label %cond27

body29:                                           ; preds = %cond27
  %vector_length32 = load i64, ptr %7, align 4
  %33 = sub i64 %vector_length32, 1
  %34 = sub i64 %33, %index26
  call void @builtin_range_check(i64 %34)
  %vector_data33 = getelementptr i64, ptr %7, i64 1
  %index_access34 = getelementptr ptr, ptr %vector_data33, i64 %index26
  %arr35 = load ptr, ptr %index_access34, align 8
  %35 = load i64, ptr %buffer_offset, align 4
  %36 = add i64 %35, 1
  store i64 %36, ptr %buffer_offset, align 4
  %37 = getelementptr ptr, ptr %17, i64 %35
  %vector_length36 = load i64, ptr %arr35, align 4
  store i64 %vector_length36, ptr %37, align 4
  store i64 0, ptr %index_ptr37, align 4
  %index38 = load i64, ptr %index_ptr37, align 4
  br label %cond39

end_for30:                                        ; preds = %cond27
  %38 = load i64, ptr %buffer_offset, align 4
  %39 = getelementptr ptr, ptr %17, i64 %38
  store i64 %16, ptr %39, align 4
  call void @set_tape_data(ptr %17, i64 %heap_size)
  ret void

cond39:                                           ; preds = %next40, %body29
  %vector_length43 = load i64, ptr %7, align 4
  %40 = sub i64 %vector_length43, 1
  %41 = sub i64 %40, %index26
  call void @builtin_range_check(i64 %41)
  %vector_data44 = getelementptr i64, ptr %7, i64 1
  %index_access45 = getelementptr i64, ptr %vector_data44, i64 %index26
  %arr46 = load ptr, ptr %index_access45, align 8
  %vector_length47 = load i64, ptr %arr46, align 4
  %42 = icmp ult i64 %index38, %vector_length47
  br i1 %42, label %body41, label %end_for42

next40:                                           ; preds = %body41
  %index55 = load i64, ptr %index_ptr37, align 4
  %43 = add i64 %index55, 1
  store i64 %43, ptr %index_ptr37, align 4
  br label %cond39

body41:                                           ; preds = %cond39
  %vector_length48 = load i64, ptr %7, align 4
  %44 = sub i64 %vector_length48, 1
  %45 = sub i64 %44, %index26
>>>>>>> 7998cf0 (fixed llvm type bug.)
  call void @builtin_range_check(i64 %45)
  %vector_data49 = getelementptr i64, ptr %7, i64 1
  %index_access50 = getelementptr i64, ptr %vector_data49, i64 %index26
  %arr51 = load ptr, ptr %index_access50, align 8
  %vector_length52 = load i64, ptr %arr51, align 4
  %46 = sub i64 %vector_length52, 1
  %47 = sub i64 %46, %index38
  call void @builtin_range_check(i64 %47)
  %vector_data53 = getelementptr i64, ptr %arr51, i64 1
  %index_access54 = getelementptr i64, ptr %vector_data53, i64 %index38
  %48 = load i64, ptr %buffer_offset, align 4
  %49 = getelementptr ptr, ptr %17, i64 %48
  store ptr %index_access54, ptr %49, align 8
  %50 = load i64, ptr %buffer_offset, align 4
  %51 = add i64 %50, 1
  store i64 %51, ptr %buffer_offset, align 4
  br label %next40

<<<<<<< HEAD
>>>>>>> b61ab64 (fixed array decode and encode bugs.)
end_for36:                                        ; preds = %cond33
  br label %next23

func_1_dispatch:                                  ; preds = %entry
  %54 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var, align 4
  %55 = load i64, ptr %offset_var, align 4
  %array_length = getelementptr ptr, ptr %54, i64 %55
  %56 = load i64, ptr %array_length, align 4
  %57 = add i64 %55, 1
  store i64 %57, ptr %offset_var, align 4
  %58 = call ptr @vector_new(i64 %56)
  store ptr %58, ptr %array_ptr, align 8
  %59 = load ptr, ptr %array_ptr, align 8
<<<<<<< HEAD
  store i64 0, ptr %index_ptr55, align 4
  br label %cond56
=======
  %vector_length59 = load i64, ptr %59, align 4
  %60 = sub i64 %vector_length59, 1
  %61 = sub i64 %60, %index52
  call void @builtin_range_check(i64 %61)
  %vector_data60 = getelementptr i64, ptr %59, i64 1
  %index_access61 = getelementptr ptr, ptr %vector_data60, i64 %index52
  %arr62 = load ptr, ptr %index_access61, align 8
  store ptr %58, ptr %arr62, align 8
  store i64 0, ptr %index_ptr63, align 4
  %index64 = load i64, ptr %index_ptr63, align 4
  br label %cond65
>>>>>>> b61ab64 (fixed array decode and encode bugs.)

cond56:                                           ; preds = %next58, %func_1_dispatch
  %vector_length60 = load i64, ptr %59, align 4
  %60 = load i64, ptr %index_ptr55, align 4
  %61 = icmp ult i64 %60, %vector_length60
  br i1 %61, label %body57, label %end_for59

body57:                                           ; preds = %cond56
  %62 = load i64, ptr %offset_var, align 4
  %63 = getelementptr ptr, ptr %54, i64 %62
  %64 = load i64, ptr %offset_var, align 4
  %array_length61 = getelementptr ptr, ptr %63, i64 %64
  %65 = load i64, ptr %array_length61, align 4
  %66 = add i64 %64, 1
  store i64 %66, ptr %offset_var, align 4
  %67 = call ptr @vector_new(i64 %65)
  %load_array = load ptr, ptr %array_ptr, align 8
  %array_index62 = load i64, ptr %index_ptr55, align 4
  %vector_length63 = load i64, ptr %load_array, align 4
  %68 = sub i64 %vector_length63, 1
  %69 = sub i64 %68, %array_index62
  call void @builtin_range_check(i64 %69)
  %vector_data64 = getelementptr i64, ptr %load_array, i64 1
  %index_access65 = getelementptr ptr, ptr %vector_data64, i64 %array_index62
  %array_element66 = load ptr, ptr %index_access65, align 8
  store ptr %67, ptr %index_access65, align 8
  %70 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr67, align 4
  br label %cond68

next58:                                           ; preds = %end_for71
  %index89 = load i64, ptr %index_ptr55, align 4
  %71 = add i64 %index89, 1
  store i64 %71, ptr %index_ptr55, align 4
  br label %cond56

end_for59:                                        ; preds = %cond56
  %72 = load ptr, ptr %array_ptr, align 8
  %73 = load i64, ptr %offset_var, align 4
  %74 = getelementptr ptr, ptr %54, i64 %73
  %75 = load i64, ptr %74, align 4
  %76 = getelementptr ptr, ptr %74, i64 1
  %77 = load i64, ptr %76, align 4
  %78 = getelementptr ptr, ptr %76, i64 1
  %79 = load i64, ptr %78, align 4
  call void @setElement(ptr %72, i64 %75, i64 %77, i64 %79)
  %80 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %80, align 4
  call void @set_tape_data(ptr %80, i64 1)
  ret void

cond68:                                           ; preds = %next70, %body57
  %array_index72 = load i64, ptr %index_ptr55, align 4
  %vector_length73 = load i64, ptr %70, align 4
  %81 = sub i64 %vector_length73, 1
  %82 = sub i64 %81, %array_index72
  call void @builtin_range_check(i64 %82)
  %vector_data74 = getelementptr i64, ptr %70, i64 1
  %index_access75 = getelementptr ptr, ptr %vector_data74, i64 %array_index72
  %array_element76 = load ptr, ptr %index_access75, align 8
  %vector_length77 = load i64, ptr %array_element76, align 4
  %83 = load i64, ptr %index_ptr67, align 4
  %84 = icmp ult i64 %83, %vector_length77
  br i1 %84, label %body69, label %end_for71

body69:                                           ; preds = %cond68
  %85 = load i64, ptr %offset_var, align 4
  %86 = getelementptr ptr, ptr %63, i64 %85
  %87 = load i64, ptr %86, align 4
  %88 = load ptr, ptr %array_ptr, align 8
  %array_index78 = load i64, ptr %index_ptr55, align 4
  %vector_length79 = load i64, ptr %88, align 4
  %89 = sub i64 %vector_length79, 1
  %90 = sub i64 %89, %array_index78
  call void @builtin_range_check(i64 %90)
  %vector_data80 = getelementptr i64, ptr %88, i64 1
  %index_access81 = getelementptr ptr, ptr %vector_data80, i64 %array_index78
  %array_element82 = load ptr, ptr %index_access81, align 8
  %array_index83 = load i64, ptr %index_ptr67, align 4
  %vector_length84 = load i64, ptr %array_element82, align 4
  %91 = sub i64 %vector_length84, 1
  %92 = sub i64 %91, %array_index83
  call void @builtin_range_check(i64 %92)
  %vector_data85 = getelementptr i64, ptr %array_element82, i64 1
  %index_access86 = getelementptr i64, ptr %vector_data85, i64 %array_index83
  %array_element87 = load i64, ptr %index_access86, align 4
  store i64 %87, ptr %index_access86, align 4
  %93 = add i64 1, %85
  store i64 %93, ptr %offset_var, align 4
  br label %next70

next70:                                           ; preds = %body69
  %index88 = load i64, ptr %index_ptr67, align 4
  %94 = add i64 %index88, 1
  store i64 %94, ptr %index_ptr67, align 4
  br label %cond68

end_for71:                                        ; preds = %cond68
  br label %next58

func_2_dispatch:                                  ; preds = %entry
  %95 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var90, align 4
  %96 = load i64, ptr %offset_var90, align 4
  %array_length92 = getelementptr ptr, ptr %95, i64 %96
  %97 = load i64, ptr %array_length92, align 4
  %98 = add i64 %96, 1
  store i64 %98, ptr %offset_var90, align 4
  %99 = call ptr @vector_new(i64 %97)
  store ptr %99, ptr %array_ptr91, align 8
  %100 = load ptr, ptr %array_ptr91, align 8
  store i64 0, ptr %index_ptr93, align 4
  br label %cond94

cond94:                                           ; preds = %next96, %func_2_dispatch
  %vector_length98 = load i64, ptr %100, align 4
  %101 = load i64, ptr %index_ptr93, align 4
  %102 = icmp ult i64 %101, %vector_length98
  br i1 %102, label %body95, label %end_for97

body95:                                           ; preds = %cond94
  %103 = load i64, ptr %offset_var90, align 4
  %104 = getelementptr ptr, ptr %95, i64 %103
  %105 = load i64, ptr %offset_var90, align 4
  %array_length99 = getelementptr ptr, ptr %104, i64 %105
  %106 = load i64, ptr %array_length99, align 4
  %107 = add i64 %105, 1
  store i64 %107, ptr %offset_var90, align 4
  %108 = call ptr @vector_new(i64 %106)
  %load_array100 = load ptr, ptr %array_ptr91, align 8
  %array_index101 = load i64, ptr %index_ptr93, align 4
  %vector_length102 = load i64, ptr %load_array100, align 4
  %109 = sub i64 %vector_length102, 1
  %110 = sub i64 %109, %array_index101
  call void @builtin_range_check(i64 %110)
  %vector_data103 = getelementptr i64, ptr %load_array100, i64 1
  %index_access104 = getelementptr ptr, ptr %vector_data103, i64 %array_index101
  %array_element105 = load ptr, ptr %index_access104, align 8
  store ptr %108, ptr %index_access104, align 8
  %111 = load ptr, ptr %array_ptr91, align 8
  store i64 0, ptr %index_ptr106, align 4
  br label %cond107

<<<<<<< HEAD
next96:                                           ; preds = %end_for110
  %index128 = load i64, ptr %index_ptr93, align 4
  %112 = add i64 %index128, 1
  store i64 %112, ptr %index_ptr93, align 4
  br label %cond94
=======
body90:                                           ; preds = %cond88
  %88 = load i64, ptr %array_offset83, align 4
  %array_length93 = load i64, ptr %82, align 4
  %89 = add i64 %88, 1
  store i64 %89, ptr %array_offset83, align 4
  %90 = call ptr @vector_new(i64 %array_length93)
  %91 = load ptr, ptr %array_ptr84, align 8
  %vector_length94 = load i64, ptr %91, align 4
  %92 = sub i64 %vector_length94, 1
  %93 = sub i64 %92, %index87
  call void @builtin_range_check(i64 %93)
  %vector_data95 = getelementptr i64, ptr %91, i64 1
  %index_access96 = getelementptr ptr, ptr %vector_data95, i64 %index87
  %arr97 = load ptr, ptr %index_access96, align 8
  store ptr %90, ptr %arr97, align 8
  store i64 0, ptr %index_ptr98, align 4
  %index99 = load i64, ptr %index_ptr98, align 4
  br label %cond100
>>>>>>> b61ab64 (fixed array decode and encode bugs.)

end_for97:                                        ; preds = %cond94
  %113 = load ptr, ptr %array_ptr91, align 8
  %114 = load i64, ptr %offset_var90, align 4
  %115 = getelementptr ptr, ptr %95, i64 %114
  %116 = load i64, ptr %115, align 4
  %117 = getelementptr ptr, ptr %115, i64 1
  %118 = load i64, ptr %117, align 4
  %119 = call i64 @getElement(ptr %113, i64 %116, i64 %118)
  %120 = call ptr @heap_malloc(i64 2)
  store i64 %119, ptr %120, align 4
  %121 = getelementptr ptr, ptr %120, i64 1
  store i64 1, ptr %121, align 4
  call void @set_tape_data(ptr %120, i64 2)
  ret void

cond107:                                          ; preds = %next109, %body95
  %array_index111 = load i64, ptr %index_ptr93, align 4
  %vector_length112 = load i64, ptr %111, align 4
  %122 = sub i64 %vector_length112, 1
  %123 = sub i64 %122, %array_index111
  call void @builtin_range_check(i64 %123)
  %vector_data113 = getelementptr i64, ptr %111, i64 1
  %index_access114 = getelementptr ptr, ptr %vector_data113, i64 %array_index111
  %array_element115 = load ptr, ptr %index_access114, align 8
  %vector_length116 = load i64, ptr %array_element115, align 4
  %124 = load i64, ptr %index_ptr106, align 4
  %125 = icmp ult i64 %124, %vector_length116
  br i1 %125, label %body108, label %end_for110

body108:                                          ; preds = %cond107
  %126 = load i64, ptr %offset_var90, align 4
  %127 = getelementptr ptr, ptr %104, i64 %126
  %128 = load i64, ptr %127, align 4
  %129 = load ptr, ptr %array_ptr91, align 8
  %array_index117 = load i64, ptr %index_ptr93, align 4
  %vector_length118 = load i64, ptr %129, align 4
  %130 = sub i64 %vector_length118, 1
  %131 = sub i64 %130, %array_index117
  call void @builtin_range_check(i64 %131)
  %vector_data119 = getelementptr i64, ptr %129, i64 1
  %index_access120 = getelementptr ptr, ptr %vector_data119, i64 %array_index117
  %array_element121 = load ptr, ptr %index_access120, align 8
  %array_index122 = load i64, ptr %index_ptr106, align 4
  %vector_length123 = load i64, ptr %array_element121, align 4
  %132 = sub i64 %vector_length123, 1
  %133 = sub i64 %132, %array_index122
  call void @builtin_range_check(i64 %133)
  %vector_data124 = getelementptr i64, ptr %array_element121, i64 1
  %index_access125 = getelementptr i64, ptr %vector_data124, i64 %array_index122
  %array_element126 = load i64, ptr %index_access125, align 4
  store i64 %128, ptr %index_access125, align 4
  %134 = add i64 1, %126
  store i64 %134, ptr %offset_var90, align 4
  br label %next109

next109:                                          ; preds = %body108
  %index127 = load i64, ptr %index_ptr106, align 4
  %135 = add i64 %index127, 1
  store i64 %135, ptr %index_ptr106, align 4
  br label %cond107

end_for110:                                       ; preds = %cond107
  br label %next96
=======
end_for42:                                        ; preds = %cond39
  br label %next28

func_1_dispatch:                                  ; preds = %entry
  %52 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset, align 4
  %53 = load i64, ptr %array_offset, align 4
  %array_length = load i64, ptr %52, align 4
  %54 = add i64 %53, 1
  store i64 %54, ptr %array_offset, align 4
  %55 = call ptr @vector_new(i64 %array_length)
  store ptr %55, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr57, align 4
  %index58 = load i64, ptr %index_ptr57, align 4
  br label %cond59

cond59:                                           ; preds = %next60, %func_1_dispatch
  %vector_length63 = load i64, ptr %array_ptr, align 4
  %56 = icmp ult i64 %index58, %vector_length63
  br i1 %56, label %body61, label %end_for62

next60:                                           ; preds = %end_for74
  %index88 = load i64, ptr %index_ptr57, align 4
  %57 = add i64 %index88, 1
  store i64 %57, ptr %index_ptr57, align 4
  br label %cond59

body61:                                           ; preds = %cond59
  %58 = load i64, ptr %array_offset, align 4
  %array_length64 = load i64, ptr %52, align 4
  %59 = add i64 %58, 1
  store i64 %59, ptr %array_offset, align 4
  %60 = call ptr @vector_new(i64 %array_length64)
  %61 = load ptr, ptr %array_ptr, align 8
  %vector_length65 = load i64, ptr %61, align 4
  %62 = sub i64 %vector_length65, 1
  %63 = sub i64 %62, %index58
  call void @builtin_range_check(i64 %63)
  %vector_data66 = getelementptr i64, ptr %61, i64 1
  %index_access67 = getelementptr ptr, ptr %vector_data66, i64 %index58
  %arr68 = load ptr, ptr %index_access67, align 8
  store ptr %60, ptr %arr68, align 8
  store i64 0, ptr %index_ptr69, align 4
  %index70 = load i64, ptr %index_ptr69, align 4
  br label %cond71

end_for62:                                        ; preds = %cond59
  %64 = load ptr, ptr %array_ptr, align 8
  %65 = load i64, ptr %array_offset, align 4
  %66 = getelementptr ptr, ptr %52, i64 %65
  %67 = load i64, ptr %66, align 4
  %68 = getelementptr ptr, ptr %66, i64 1
  %69 = load i64, ptr %68, align 4
  %70 = getelementptr ptr, ptr %68, i64 1
  %71 = load i64, ptr %70, align 4
  call void @setElement(ptr %64, i64 %67, i64 %69, i64 %71)
  %72 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %72, align 4
  call void @set_tape_data(ptr %72, i64 1)
  ret void

cond71:                                           ; preds = %next72, %body61
  %vector_length75 = load i64, ptr %array_ptr, align 4
  %73 = sub i64 %vector_length75, 1
  %74 = sub i64 %73, %index58
  call void @builtin_range_check(i64 %74)
  %vector_data76 = getelementptr i64, ptr %array_ptr, i64 1
  %index_access77 = getelementptr ptr, ptr %vector_data76, i64 %index58
  %arr78 = load ptr, ptr %index_access77, align 8
  %vector_length79 = load i64, ptr %arr78, align 4
  %75 = icmp ult i64 %index70, %vector_length79
  br i1 %75, label %body73, label %end_for74

next72:                                           ; preds = %body73
  %index87 = load i64, ptr %index_ptr69, align 4
  %76 = add i64 %index87, 1
  store i64 %76, ptr %index_ptr69, align 4
  br label %cond71

body73:                                           ; preds = %cond71
  %77 = load i64, ptr %52, align 4
  %78 = load ptr, ptr %array_ptr, align 8
  %vector_length80 = load i64, ptr %78, align 4
  %79 = sub i64 %vector_length80, 1
  %80 = sub i64 %79, %index58
  call void @builtin_range_check(i64 %80)
  %vector_data81 = getelementptr i64, ptr %78, i64 1
  %index_access82 = getelementptr ptr, ptr %vector_data81, i64 %index58
  %arr83 = load ptr, ptr %index_access82, align 8
  %vector_length84 = load i64, ptr %arr83, align 4
  %81 = sub i64 %vector_length84, 1
  %82 = sub i64 %81, %index70
  call void @builtin_range_check(i64 %82)
  %vector_data85 = getelementptr i64, ptr %arr83, i64 1
  %index_access86 = getelementptr i64, ptr %vector_data85, i64 %index70
  store i64 %77, ptr %index_access86, align 4
  %83 = add i64 1, %58
  store i64 %83, ptr %array_offset, align 4
  br label %next72

end_for74:                                        ; preds = %cond71
  br label %next60

func_2_dispatch:                                  ; preds = %entry
  %84 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset89, align 4
  %85 = load i64, ptr %array_offset89, align 4
  %array_length91 = load i64, ptr %84, align 4
  %86 = add i64 %85, 1
  store i64 %86, ptr %array_offset89, align 4
  %87 = call ptr @vector_new(i64 %array_length91)
  store ptr %87, ptr %array_ptr90, align 8
  store i64 0, ptr %index_ptr92, align 4
  %index93 = load i64, ptr %index_ptr92, align 4
  br label %cond94

cond94:                                           ; preds = %next95, %func_2_dispatch
  %vector_length98 = load i64, ptr %array_ptr90, align 4
  %88 = icmp ult i64 %index93, %vector_length98
  br i1 %88, label %body96, label %end_for97

next95:                                           ; preds = %end_for109
  %index123 = load i64, ptr %index_ptr92, align 4
  %89 = add i64 %index123, 1
  store i64 %89, ptr %index_ptr92, align 4
  br label %cond94

body96:                                           ; preds = %cond94
  %90 = load i64, ptr %array_offset89, align 4
  %array_length99 = load i64, ptr %84, align 4
  %91 = add i64 %90, 1
  store i64 %91, ptr %array_offset89, align 4
  %92 = call ptr @vector_new(i64 %array_length99)
  %93 = load ptr, ptr %array_ptr90, align 8
  %vector_length100 = load i64, ptr %93, align 4
  %94 = sub i64 %vector_length100, 1
  %95 = sub i64 %94, %index93
  call void @builtin_range_check(i64 %95)
  %vector_data101 = getelementptr i64, ptr %93, i64 1
  %index_access102 = getelementptr ptr, ptr %vector_data101, i64 %index93
  %arr103 = load ptr, ptr %index_access102, align 8
  store ptr %92, ptr %arr103, align 8
  store i64 0, ptr %index_ptr104, align 4
  %index105 = load i64, ptr %index_ptr104, align 4
  br label %cond106

end_for97:                                        ; preds = %cond94
  %96 = load ptr, ptr %array_ptr90, align 8
  %97 = load i64, ptr %array_offset89, align 4
  %98 = getelementptr ptr, ptr %84, i64 %97
  %99 = load i64, ptr %98, align 4
  %100 = getelementptr ptr, ptr %98, i64 1
  %101 = load i64, ptr %100, align 4
  %102 = call i64 @getElement(ptr %96, i64 %99, i64 %101)
  %103 = call ptr @heap_malloc(i64 2)
  store i64 %102, ptr %103, align 4
  %104 = getelementptr ptr, ptr %103, i64 1
  store i64 1, ptr %104, align 4
  call void @set_tape_data(ptr %103, i64 2)
  ret void

cond106:                                          ; preds = %next107, %body96
  %vector_length110 = load i64, ptr %array_ptr90, align 4
  %105 = sub i64 %vector_length110, 1
  %106 = sub i64 %105, %index93
  call void @builtin_range_check(i64 %106)
  %vector_data111 = getelementptr i64, ptr %array_ptr90, i64 1
  %index_access112 = getelementptr ptr, ptr %vector_data111, i64 %index93
  %arr113 = load ptr, ptr %index_access112, align 8
  %vector_length114 = load i64, ptr %arr113, align 4
  %107 = icmp ult i64 %index105, %vector_length114
  br i1 %107, label %body108, label %end_for109

next107:                                          ; preds = %body108
  %index122 = load i64, ptr %index_ptr104, align 4
  %108 = add i64 %index122, 1
  store i64 %108, ptr %index_ptr104, align 4
  br label %cond106

body108:                                          ; preds = %cond106
  %109 = load i64, ptr %84, align 4
  %110 = load ptr, ptr %array_ptr90, align 8
  %vector_length115 = load i64, ptr %110, align 4
  %111 = sub i64 %vector_length115, 1
  %112 = sub i64 %111, %index93
  call void @builtin_range_check(i64 %112)
  %vector_data116 = getelementptr i64, ptr %110, i64 1
  %index_access117 = getelementptr ptr, ptr %vector_data116, i64 %index93
  %arr118 = load ptr, ptr %index_access117, align 8
  %vector_length119 = load i64, ptr %arr118, align 4
  %113 = sub i64 %vector_length119, 1
  %114 = sub i64 %113, %index105
  call void @builtin_range_check(i64 %114)
  %vector_data120 = getelementptr i64, ptr %arr118, i64 1
  %index_access121 = getelementptr i64, ptr %vector_data120, i64 %index105
  store i64 %109, ptr %index_access121, align 4
  %115 = add i64 1, %90
  store i64 %115, ptr %array_offset89, align 4
  br label %next107

end_for109:                                       ; preds = %cond106
  br label %next95
>>>>>>> 7998cf0 (fixed llvm type bug.)
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
