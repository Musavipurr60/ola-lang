; ModuleID = 'NonceHolder'
source_filename = "examples/source/types/mapping.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
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

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @setNonce(ptr %0, i64 %1) {
entry:
  %_nonceSet = alloca i64, align 8
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %8 = inttoptr i64 %heap_start1 to ptr
  call void @mempcy(ptr %heap_to_ptr, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @mempcy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %10, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %11, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 8)
  %heap_start7 = sub i64 %16, 8
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %17 = inttoptr i64 %heap_start7 to ptr
  call void @mempcy(ptr %heap_to_ptr4, ptr %17, i64 4)
  %next_dest_offset9 = add i64 %heap_start7, 4
  %18 = inttoptr i64 %next_dest_offset9 to ptr
  call void @mempcy(ptr %heap_to_ptr6, ptr %18, i64 4)
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr11, i64 8)
  %20 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %20, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 55, ptr %heap_to_ptr13, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 0, ptr %23, align 4
  call void @set_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr13)
  %24 = load ptr, ptr %_address, align 8
  %25 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %25, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 0, ptr %heap_to_ptr15, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %28, align 4
  %29 = call i64 @vector_new(i64 8)
  %heap_start16 = sub i64 %29, 8
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %30 = inttoptr i64 %heap_start16 to ptr
  call void @mempcy(ptr %heap_to_ptr15, ptr %30, i64 4)
  %next_dest_offset18 = add i64 %heap_start16, 4
  %31 = inttoptr i64 %next_dest_offset18 to ptr
  call void @mempcy(ptr %24, ptr %31, i64 4)
  %32 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %32, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr17, ptr %heap_to_ptr20, i64 8)
  %33 = load i64, ptr %_nonce, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %34, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 %33, ptr %heap_to_ptr22, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %37, align 4
  %38 = call i64 @vector_new(i64 8)
  %heap_start23 = sub i64 %38, 8
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %39 = inttoptr i64 %heap_start23 to ptr
  call void @mempcy(ptr %heap_to_ptr20, ptr %39, i64 4)
  %next_dest_offset25 = add i64 %heap_start23, 4
  %40 = inttoptr i64 %next_dest_offset25 to ptr
  call void @mempcy(ptr %heap_to_ptr22, ptr %40, i64 4)
  %41 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %41, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr24, ptr %heap_to_ptr27, i64 8)
  %42 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %42, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  call void @get_storage(ptr %heap_to_ptr27, ptr %heap_to_ptr29)
  %storage_value = load i64, ptr %heap_to_ptr29, align 4
  store i64 %storage_value, ptr %_nonceSet, align 4
  %43 = load i64, ptr %_nonceSet, align 4
  call void @prophet_printf(i64 %43, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3694669121, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = add i64 %input_start, 4
  %5 = inttoptr i64 %4 to ptr
  %decode_value = load i64, ptr %5, align 4
  call void @setNonce(ptr %3, i64 %decode_value)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}