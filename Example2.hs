{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}

module Example2 where

import LLVM.AST as AST
import LLVM.Quote.LLVM as Q

-- saxpy matrix kernel
-- https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms#Level_1

saxpy :: AST.Module
saxpy = [Q.llmod|
; ModuleID = 'saxpy.ll'

; (from: https://llvm.org/docs/LangRef.html#llvm-donothing-intrinsic)
; (from: https://stackoverflow.com/a/29419659/2885946)
declare void @llvm.donothing() nounwind readnone

define void @saxpy(i32* noalias nocapture %x, i32* noalias nocapture %y, i32 %a, i64 %i) {
entry:
  %1 = getelementptr inbounds i32, i32* %x, i64 %i
    call void @llvm.donothing()
  %2 = load i32, i32* %1, align 4
  %3 = mul nsw i32 %2, %a
    call void @llvm.donothing()
  %4 = getelementptr inbounds i32, i32* %y, i64 %i
    call void @llvm.donothing()
  %5 = load i32, i32* %4, align 4
  %6 = add nsw i32 %3, %5
  store i32 %6, i32* %1, align 4
  %7 = add i64 %i, 1
  %8 = getelementptr inbounds i32, i32* %x, i64 %7
    call void @llvm.donothing()
  %9 = load i32, i32* %8, align 4
  %10 = mul nsw i32 %9, %a
    call void @llvm.donothing()
  %11 = getelementptr inbounds i32, i32* %y, i64 %7
    call void @llvm.donothing()
  %12 = load i32, i32* %11, align 4
  %13 = add nsw i32 %10, %12
  store i32 %13, i32* %8, align 4
  %14 = add i64 %i, 2
  %15 = getelementptr inbounds i32, i32* %x, i64 %14
    call void @llvm.donothing()
  %16 = load i32, i32* %15, align 4
  %17 = mul nsw i32 %16, %a
    call void @llvm.donothing()
  %18 = getelementptr inbounds i32, i32* %y, i64 %14
    call void @llvm.donothing()
  %19 = load i32, i32* %18, align 4
  %20 = add nsw i32 %17, %19
  store i32 %20, i32* %15, align 4
  %21 = add i64 %i, 3
  %22 = getelementptr inbounds i32, i32* %x, i64 %21
    call void @llvm.donothing()
  %23 = load i32, i32* %22, align 4
  %24 = mul nsw i32 %23, %a
    call void @llvm.donothing()
  %25 = getelementptr inbounds i32, i32* %y, i64 %21
    call void @llvm.donothing()
  %26 = load i32, i32* %25, align 4
  %27 = add nsw i32 %24, %26
  store i32 %27, i32* %22, align 4
  ret void
}
|]
