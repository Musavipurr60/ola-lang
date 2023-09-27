; ModuleID = 'StaticArrayExample'
source_filename = "examples/source/storage/storage_array.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

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

define void @init() {
entry:
  %0 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %array_literal = alloca [5 x i64], align 8
  %elemptr0 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 4
  store i64 5, ptr %elemptr4, align 4
  store i64 0, ptr %index_alloca, align 4
  store i64 0, ptr %0, align 4
  br label %body

body:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %1 = load i64, ptr %0, align 4
  %index_access = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 %index_value
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %1, ptr %heap_to_ptr, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %5, align 4
  call void @set_storage(ptr %heap_to_ptr, ptr %index_access)
  %6 = add i64 %1, 1
  store i64 %6, ptr %0, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %next_index, 5
  br i1 %loop_cond, label %body, label %done

done:                                             ; preds = %body
  ret void
}

define void @setElement(i64 %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %index = alloca i64, align 8
  store i64 %0, ptr %index, align 4
  store i64 %1, ptr %value, align 4
  %2 = load i64, ptr %index, align 4
  %3 = sub i64 4, %2
  call void @builtin_range_check(i64 %3)
  %index_offset = mul i64 %2, 1
  %index_slot = add i64 0, %index_offset
  %4 = load i64, ptr %value, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %5, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %index_slot, ptr %heap_to_ptr, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %8, align 4
  %9 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %9, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 %4, ptr %heap_to_ptr2, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %12, align 4
  call void @set_storage(ptr %heap_to_ptr, ptr %heap_to_ptr2)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 708429793, label %func_0_dispatch
    i64 2209048891, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @init()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 2, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %4 = icmp ult i64 2, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setElement(i64 %value, i64 %value2)
  ret void
}

define void @call() {
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
