{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module LLVM.Quote.Test.Instructions where

import Test.Tasty
import Test.Tasty.HUnit

import LLVM.Quote.LLVM

import LLVM.AST
import LLVM.AST.AddrSpace
import LLVM.AST.Type
import qualified LLVM.AST.IntegerPredicate as IPred
import qualified LLVM.AST.FloatingPointPredicate as FPPred
import qualified LLVM.AST.CallingConvention as CC
import qualified LLVM.AST.Global as G
import qualified LLVM.AST.Constant as C
import qualified LLVM.AST.RMWOperation as RMWOp
import qualified LLVM.AST.Float as Float

instruction :: Type -> Operand -> Instruction
instruction ty op = [lli| call void @dummy_fuc($type:ty $opr:op) |]

terminator :: Terminator
terminator = [llt| ret i32 0 |]

brWithName :: Name -> Name -> Name -> Instruction
brWithName condName n1 n2 = [lli|br i1 $id:condName, label $id:n1, label $id:n2|]

brWithOp :: Operand -> Name -> Name -> Instruction
brWithOp cond n1 n2 = [lli|br $opr:cond, label $id:n1, label $id:n2|]

phi1 :: Type -> Name -> Name -> Name -> Name -> Instruction
phi1 ty vName1 vName2 label1 label2 = [lli|phi $type:ty [$id:vName1, $id:label1], [$id:vName2, $id:label2]|]

phi2 :: Type -> Operand -> Operand -> Name -> Name -> Instruction
phi2 ty op1 op2 label1 label2 = [lli|phi $type:ty [$opr:op1, $id:label1], [$opr:op2, $id:label2]|]


retWithName :: Type -> Name -> Terminator
retWithName ty name = [llt|ret $type:ty $id:name|]

retWithOp :: Type -> Operand -> Terminator
retWithOp ty op = [llt|ret $type:ty $opr:op|]


tests :: TestTree
tests = let a t = LocalReference t . UnName in testGroup "Instructions" [
  testGroup "regular" [
    testCase name $ instrQ @?= instr
    | (name, instr, instrQ) <- [
          ("add",
           Add {
             nsw = False,
             nuw = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|add i32 %0, %0|]),
          ("nsw",
           Add {
             nsw = True,
             nuw = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|add nsw i32 %0, %0|]),
          ("nuw",
           Add {
             nsw = False,
             nuw = True,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|add nuw i32 %0, %0|]),
          ("fadd",
           FAdd {
             fastMathFlags = NoFastMathFlags,
             operand0 = a float 1,
             operand1 = a float 1,
             metadata = []
           },
           [lli|fadd float %1, %1|]),
          ("sub",
           Sub {
             nsw = False,
             nuw = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|sub i32 %0, %0|]),
          ("fsub",
           FSub {
             fastMathFlags = NoFastMathFlags,
             operand0 = a float 1,
             operand1 = a float 1,
             metadata = []
           },
           [lli|fsub float %1, %1|]),
          ("mul",
           Mul {
             nsw = False,
             nuw = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|mul i32 %0, %0|]),
          ("fmul",
           FMul {
             fastMathFlags = NoFastMathFlags,
             operand0 = a float 1,
             operand1 = a float 1,
             metadata = []
           },
           [lli|fmul float %1, %1|]),
          ("udiv",
           UDiv {
             exact = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|udiv i32 %0, %0|]),
          ("exact",
           UDiv {
             exact = True,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|udiv exact i32 %0, %0|]),
          ("sdiv",
           SDiv {
             exact = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|sdiv i32 %0, %0|]),
          ("fdiv",
           FDiv {
             fastMathFlags = NoFastMathFlags,
             operand0 = a float 1,
             operand1 = a float 1,
             metadata = []
           },
           [lli|fdiv float %1, %1|]),
          ("urem",
           URem {
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|urem i32 %0, %0|]),
          ("srem",
           SRem {
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|srem i32 %0, %0|]),
          ("frem",
           FRem {
             fastMathFlags = NoFastMathFlags,
             operand0 = a float 1,
             operand1 = a float 1,
             metadata = []
           },
           [lli|frem float %1, %1|]),
          ("shl",
           Shl {
             nsw = False,
             nuw = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|shl i32 %0, %0|]),
          ("ashr",
           AShr {
             exact = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|ashr i32 %0, %0|]),
          ("lshr",
           LShr {
             exact = False,
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|lshr i32 %0, %0|]),
          ("and",
           And {
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|and i32 %0, %0|]),
          ("or",
           Or {
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|or i32 %0, %0|]),
          ("xor",
           Xor {
             operand0 = a i32 0,
             operand1 = a i32 0,
             metadata = []
           },
           [lli|xor i32 %0, %0|]),
          ("alloca",
           Alloca {
             allocatedType = IntegerType 32,
             numElements = Nothing,
             alignment = 0,
             metadata = []
           },
           [lli|alloca i32|]),
          ("alloca tricky",
           Alloca {
             allocatedType = IntegerType 7,
             numElements = Just (ConstantOperand (C.Int 32 2)),
             alignment = 128,
             metadata = []
           },
           [lli|alloca i7, i32 2, align 128|]),
          ("load",
           Load {
             volatile = False,
             address = a (ptr i32) 2,
             maybeAtomicity = Nothing,
             alignment = 0,
             metadata = []
           },
           [lli|load i32* %2|]),
          ("volatile",
           Load {
             volatile = True,
             address = a (ptr i32) 2,
             maybeAtomicity = Nothing,
             alignment = 0,
             metadata = []
           },
           [lli|load volatile i32* %2|]),
          ("acquire",
           Load {
             volatile = False,
             address = a (ptr i32) 2,
             maybeAtomicity = Just (System, Acquire),
             alignment = 1,
             metadata = []
           },
           [lli|load atomic i32* %2 acquire, align 1|]),
          ("singlethread",
           Load {
             volatile = False,
             address = a (ptr i32) 2,
             maybeAtomicity = Just (SingleThread, Monotonic),
             alignment = 1,
             metadata = []
           },
           [lli|load atomic i32* %2 singlethread monotonic, align 1|]),
          ("GEP",
           GetElementPtr {
             inBounds = False,
             address = a (ptr i32) 2,
             indices = [ a i32 0 ],
             metadata = []
           },
           [lli|getelementptr i32* %2, i32 %0|]),
          ("inBounds",
           GetElementPtr {
             inBounds = True,
             address = a (ptr i32) 2,
             indices = [ a i32 0 ],
             metadata = []
           },
           [lli|getelementptr inbounds i32* %2, i32 %0|]),
          ("cmpxchg",
           CmpXchg {
             volatile = False,
             address = a (ptr i32) 2,
             expected = a i32 0,
             replacement = a i32 0,
             atomicity = (System, Monotonic),
             metadata = [],
             failureMemoryOrdering = Unordered
           },
           [lli|cmpxchg i32* %2, i32 %0, i32 %0 monotonic|]),
          ("atomicrmw",
           AtomicRMW {
             volatile = False,
             rmwOperation = RMWOp.UMax,
             address = a (ptr i32) 2,
             value = a i32 0,
             atomicity = (System, Release),
             metadata = []
           },
           [lli|atomicrmw umax i32* %2, i32 %0 release|]),

          ("trunc",
           Trunc {
             operand0 = a i32 0,
             type' = IntegerType 16,
             metadata = []
           },
           [lli|trunc i32 %0 to i16|]),
          ("zext",
           ZExt {
             operand0 = a i32 0,
             type' = IntegerType 64,
             metadata = []
           },
           [lli|zext i32 %0 to i64|]),
          ("sext",
           SExt {
             operand0 = a i32 0,
             type' = IntegerType 64,
             metadata = []
           },
           [lli|sext i32 %0 to i64|]),
          ("fptoui",
           FPToUI {
             operand0 = a float 1,
             type' = IntegerType 64,
             metadata = []
           },
           [lli|fptoui float %1 to i64|]),
          ("fptosi",
           FPToSI {
             operand0 = a float 1,
             type' = IntegerType 64,
             metadata = []
           },
           [lli|fptosi float %1 to i64|]),
          ("uitofp",
           UIToFP {
             operand0 = a i32 0,
             type' = FloatingPointType FloatFP,
             metadata = []
           },
           [lli|uitofp i32 %0 to float|]),
          ("sitofp",
           SIToFP {
             operand0 = a i32 0,
             type' = FloatingPointType FloatFP,
             metadata = []
           },
           [lli|sitofp i32 %0 to float|]),
          ("fptrunc",
           FPTrunc {
             operand0 = a float 1,
             type' = FloatingPointType HalfFP,
             metadata = []
           },
           [lli|fptrunc float %1 to half|]),
          ("fpext",
           FPExt {
             operand0 = a float 1,
             type' = FloatingPointType DoubleFP,
             metadata = []
           },
           [lli|fpext float %1 to double|]),
          ("ptrtoint",
           PtrToInt {
             operand0 = a (ptr i32) 2,
             type' = IntegerType 32,
             metadata = []
           },
           [lli|ptrtoint i32* %2 to i32|]),
          ("inttoptr",
           IntToPtr {
             operand0 = a i32 0,
             type' = PointerType (IntegerType 32) (AddrSpace 0),
             metadata = []
           },
           [lli|inttoptr i32 %0 to i32*|]),
          ("bitcast",
           BitCast {
             operand0 = a i32 0,
             type' = FloatingPointType FloatFP,
             metadata = []
           },
           [lli|bitcast i32 %0 to float|]),
          ("addrspacecast",
           AddrSpaceCast {
             operand0 = a (ptr i32) 2,
             type' = PointerType (IntegerType 32) (AddrSpace 2),
             metadata = []
           },
           [lli|addrspacecast i32* %2 to i32 addrspace(2)*|]),
          ("select",
           Select {
             condition' = a i1 4,
             trueValue = a i32 0,
             falseValue = a i32 0,
             metadata = []
           },
           [lli|select i1 %4, i32 %0, i32 %0|]),
          ("vaarg",
           VAArg {
             argList = a (ptr i32) 2,
             type' = IntegerType 16,
             metadata = []
           },
           [lli|va_arg i32* %2, i16|]),
          ("extractelement",
           ExtractElement {
             vector = a (VectorType 2 i32) 5,
             index = a i32 0,
             metadata = []
           },
           [lli|extractelement <2 x i32> %5, i32 %0|]),
          ("insertelement",
           InsertElement {
             vector = a (VectorType 2 i32) 5,
             element = a i32 0,
             index = a i32 0,
             metadata = []
           },
           [lli|insertelement <2 x i32> %5, i32 %0, i32 %0|]),
          ("shufflevector",
           ShuffleVector {
             operand0 = a (VectorType 2 i32) 5,
             operand1 = a (VectorType 2 i32) 5,
             mask = C.Vector [ C.Int 32 p | p <- [0..1] ],
             metadata = []
           },
           [lli|shufflevector <2 x i32> %5, <2 x i32> %5, <2 x i32> <i32 0, i32 1>|]),
          ("extractvalue",
           ExtractValue {
             aggregate = a (StructureType False [i32, i32]) 6,
             indices' = [0],
             metadata = []
           },
           [lli|extractvalue { i32, i32 } %6, 0|]),
          ("insertvalue",
           InsertValue {
             aggregate = a (StructureType False [i32, i32]) 6,
             element = a i32 0,
             indices' = [0],
             metadata = []
           },
           [lli|insertvalue { i32, i32 } %6, i32 %0, 0|]),
          ("landingpad-catch",
           LandingPad {
             type' = StructureType False [
                PointerType (IntegerType 8) (AddrSpace 0),
                IntegerType 32
               ],
             cleanup = False,
             clauses = [Catch (C.Null (PointerType (IntegerType 8) (AddrSpace 0)))],
             metadata = []
           },
           [lli|landingpad { i8*, i32 } catch i8* null|]),
          ("landingpad-filter",
           LandingPad {
             type' = StructureType False [
                PointerType (IntegerType 8) (AddrSpace 0),
                IntegerType 32
               ],
             cleanup = False,
             clauses = [Filter (C.Null (ArrayType 1 (PointerType (IntegerType 8) (AddrSpace 0))))],
             metadata = []
           },
           [lli|landingpad { i8*, i32 } filter [1 x i8*] zeroinitializer|]),
          ("landingpad-catch-cleanup",
           LandingPad {
             type' = StructureType False [
                PointerType (IntegerType 8) (AddrSpace 0),
                IntegerType 32
               ],
             cleanup = True,
             clauses = [Catch (C.Null (PointerType (IntegerType 8) (AddrSpace 0)))],
             metadata = []
           },
           [lli|landingpad { i8*, i32 } cleanup catch i8* null|]),
          ("landingpad-filter-cleanup",
           LandingPad {
             type' = StructureType False [
                PointerType (IntegerType 8) (AddrSpace 0),
                IntegerType 32
               ],
             cleanup = True,
             clauses = [Filter (C.Null (ArrayType 1 (PointerType (IntegerType 8) (AddrSpace 0))))],
             metadata = []
           },
           [lli|landingpad { i8*, i32 } cleanup filter [1 x i8*] zeroinitializer|]),
          ("icmp-eq",
           ICmp { iPredicate = IPred.EQ, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp eq i32 %0, %0|]),
          ("icmp-ne",
           ICmp { iPredicate = IPred.NE, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp ne i32 %0, %0|]),
          ("icmp-ugt",
           ICmp { iPredicate = IPred.UGT, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp ugt i32 %0, %0|]),
          ("icmp-uge",
           ICmp { iPredicate = IPred.UGE, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp uge i32 %0, %0|]),
          ("icmp-ult",
           ICmp { iPredicate = IPred.ULT, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp ult i32 %0, %0|]),
          ("icmp-ule",
           ICmp { iPredicate = IPred.ULE, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp ule i32 %0, %0|]),
          ("icmp-sgt",
           ICmp { iPredicate = IPred.SGT, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp sgt i32 %0, %0|]),
          ("icmp-sge",
           ICmp { iPredicate = IPred.SGE, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp sge i32 %0, %0|]),
          ("icmp-slt",
           ICmp { iPredicate = IPred.SLT, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp slt i32 %0, %0|]),
          ("icmp-sle",
           ICmp { iPredicate = IPred.SLE, operand0 = a i32 0, operand1 = a i32 0, metadata = [] },
           [lli|icmp sle i32 %0, %0|]),
          ("fcmp-false",
           FCmp { fpPredicate = FPPred.False, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp false float %1, %1|]),
          ("fcmp-oeq",
           FCmp { fpPredicate = FPPred.OEQ, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp oeq float %1, %1|]),
          ("fcmp-ogt",
           FCmp { fpPredicate = FPPred.OGT, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ogt float %1, %1|]),
          ("fcmp-oge",
           FCmp { fpPredicate = FPPred.OGE, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp oge float %1, %1|]),
          ("fcmp-olt",
           FCmp { fpPredicate = FPPred.OLT, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp olt float %1, %1|]),
          ("fcmp-ole",
           FCmp { fpPredicate = FPPred.OLE, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ole float %1, %1|]),
          ("fcmp-one",
           FCmp { fpPredicate = FPPred.ONE, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp one float %1, %1|]),
          ("fcmp-ord",
           FCmp { fpPredicate = FPPred.ORD, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ord float %1, %1|]),
          ("fcmp-uno",
           FCmp { fpPredicate = FPPred.UNO, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp uno float %1, %1|]),
          ("fcmp-ueq",
           FCmp { fpPredicate = FPPred.UEQ, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ueq float %1, %1|]),
          ("fcmp-ugt",
           FCmp { fpPredicate = FPPred.UGT, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ugt float %1, %1|]),
          ("fcmp-uge",
           FCmp { fpPredicate = FPPred.UGE, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp uge float %1, %1|]),
          ("fcmp-ult",
           FCmp { fpPredicate = FPPred.ULT, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ult float %1, %1|]),
          ("fcmp-ule",
           FCmp { fpPredicate = FPPred.ULE, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp ule float %1, %1|]),
          ("fcmp-une",
           FCmp { fpPredicate = FPPred.UNE, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp une float %1, %1|]),
          ("fcmp-true",
           FCmp { fpPredicate = FPPred.True, operand0 = a float 1, operand1 = a float 1, metadata = [] },
           [lli|fcmp true float %1, %1|]),
          ("store",
          Store {
            volatile = False,
            address = a (ptr i32) 2,
            value = a i32 0,
            maybeAtomicity = Nothing,
            alignment = 0,
            metadata = []
          },
          [lli|store i32 %0, i32* %2|]),
         ("fence",
          Fence {
            atomicity = (System, Acquire),
            metadata = []
          },
          [lli|fence acquire|]),
          ("call",
           Call {
             tailCallKind = Nothing,
             callingConvention = CC.C,
             returnAttributes = [],
             function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32, float, ptr i32, i64, i1, (VectorType 2 i32), (StructureType False [i32, i32])] False)) (UnName 0))),
             arguments = [ (LocalReference i32 (UnName 0), [])
                         , (LocalReference float (UnName 1), [])
                         , (LocalReference (ptr i32) (UnName 2), [])
                         , (LocalReference i64 (UnName 3), [])
                         , (LocalReference i1 (UnName 4), [])
                         , (LocalReference (VectorType 2 i32) (UnName 5), [])
                         , (LocalReference (StructureType False [i32, i32]) (UnName 6), [])
                         ],
             functionAttributes = [],
             metadata = []
           },
           [lli|call void @0(i32 %0, float %1, i32* %2, i64 %3, i1 %4, <2 x i32> %5, { i32, i32 } %6)|]),
           ("call with constant bitcast",
             Call {
               tailCallKind = Nothing,
               callingConvention = CC.C,
               returnAttributes = [],
               function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [ptr i8] False)) (Name "myfunc"))),
               arguments = [ (ConstantOperand (C.BitCast (C.GlobalReference (ptr i1) (Name "myglobal")) (ptr i8)), [])
                           ],
               functionAttributes = [],
               metadata = []
             },
             [lli|call void @myfunc(i8* bitcast (i1* @myglobal to i8*))|]),
             ("call with nested constant bitcast",
               Call {
                 tailCallKind = Nothing,
                 callingConvention = CC.C,
                 returnAttributes = [],
                 function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [ptr i8] False)) (Name "myfunc"))),
                 arguments = [ (ConstantOperand (C.BitCast (C.BitCast (C.GlobalReference (ptr i1) (Name "myglobal")) (ptr (IntegerType 3))) (ptr i8)), [])
                             ],
                 functionAttributes = [],
                 metadata = []
               },
               [lli|call void @myfunc(i8* bitcast (i3* bitcast (i1* @myglobal to i3*) to i8*))|]),
             ("call with constant add",
               Call {
                 tailCallKind = Nothing,
                 callingConvention = CC.C,
                 returnAttributes = [],
                 function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32] False)) (Name "myfunc2"))),
                 arguments = [ (ConstantOperand (C.Add False False (C.Int 32 1) (C.Int 32 2)), [])
                             ],
                 functionAttributes = [],
                 metadata = []
               },
               [lli|call void @myfunc2(i32 add (i32 1, i32 2))|]),
               ("call with constant add nsw",
                 Call {
                   tailCallKind = Nothing,
                   callingConvention = CC.C,
                   returnAttributes = [],
                   function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32] False)) (Name "myfunc2"))),
                   arguments = [ (ConstantOperand (C.Add True False (C.Int 32 1) (C.Int 32 2)), [])
                               ],
                   functionAttributes = [],
                   metadata = []
                 },
                 [lli|call void @myfunc2(i32 add nsw (i32 1, i32 2))|]),
               ("call with constant add nsw",
                 Call {
                   tailCallKind = Nothing,
                   callingConvention = CC.C,
                   returnAttributes = [],
                   function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32] False)) (Name "myfunc2"))),
                   arguments = [ (ConstantOperand (C.Add False True (C.Int 32 1) (C.Int 32 2)), [])
                               ],
                   functionAttributes = [],
                   metadata = []
                 },
                 [lli|call void @myfunc2(i32 add nuw (i32 1, i32 2))|]),
               ("call with constant add nsw",
                 Call {
                   tailCallKind = Nothing,
                   callingConvention = CC.C,
                   returnAttributes = [],
                   function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32] False)) (Name "myfunc2"))),
                   arguments = [ (ConstantOperand (C.Add True True (C.Int 32 1) (C.Int 32 2)), [])
                               ],
                   functionAttributes = [],
                   metadata = []
                 },
                 [lli|call void @myfunc2(i32 add nsw nuw (i32 1, i32 2))|]),
               ("call with constant fadd",
                 Call {
                   tailCallKind = Nothing,
                   callingConvention = CC.C,
                   returnAttributes = [],
                   function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [float] False)) (Name "myfunc3"))),
                   arguments = [ (ConstantOperand (C.FAdd (C.Float (Float.Single 0.5)) (C.Float (Float.Single 0.25))), [])
                               ],
                   functionAttributes = [],
                   metadata = []
                 },
                 [lli|call void @myfunc3(float fadd (float 0.5, float 0.25))|]),
               ("call with constant getelementptr",
                 Call {
                   tailCallKind = Nothing,
                   callingConvention = CC.C,
                   returnAttributes = [],
                   function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [ptr i8] False)) (Name "myfunc"))),
                   arguments = [ (ConstantOperand (C.GetElementPtr False ((C.GlobalReference (ptr (ArrayType 4 i8)) (Name "myglobal_str"))) [C.Int 32 0, C.Int 32 0]), [])
                               ],
                   functionAttributes = [],
                   metadata = []
                 },
                 [lli|call void @myfunc(i8* getelementptr ([4 x i8]* @myglobal_str, i32 0, i32 0))|]),
               ("call with constant getelementptr inbounds",
                Call {
                  tailCallKind = Nothing,
                  callingConvention = CC.C,
                  returnAttributes = [],
                  function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [ptr i8] False)) (Name "myfunc"))),
                  arguments = [ (ConstantOperand (C.GetElementPtr True (C.GlobalReference (ptr (ArrayType 4 i8)) (Name "myglobal_str")) [C.Int 32 0, C.Int 32 0]), [])
                              ],
                  functionAttributes = [],
                  metadata = []
                },
                [lli|call void @myfunc(i8* getelementptr inbounds ([4 x i8]* @myglobal_str, i32 0, i32 0))|]),
               ("call with constant ptrtoint",
                Call {
                  tailCallKind = Nothing,
                  callingConvention = CC.C,
                  returnAttributes = [],
                  function = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32] False)) (Name "myfunc2"))),
                  arguments = [ (ConstantOperand (C.PtrToInt (C.GlobalReference (ptr i8) (Name "myptr")) i32), [])
                              ],
                  functionAttributes = [],
                  metadata = []
                },
                [lli|call void @myfunc2(i32 ptrtoint (i8* @myptr to i32))|])
         ]
   ],

   testGroup "terminators" [
    testCase name $ mASTQ @?= mAST
    | (name, mAST, mASTQ) <- [
     (
       "ret",
       Module "<string>" "<string>" Nothing Nothing [
        GlobalDefinition $ functionDefaults {
          G.returnType = VoidType,
          G.name = UnName 0,
          G.basicBlocks = [
            BasicBlock (Name "entry") [
             ] (
              Do $ Ret Nothing []
             )
           ]
         }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0() {
       entry:
         ret void
       }|]
     ), (
       "br",
       Module "<string>" "<string>" Nothing Nothing [
        GlobalDefinition $ functionDefaults {
          G.returnType = VoidType,
          G.name = UnName 0,
          G.basicBlocks = [
            BasicBlock (Name "entry") [] (
              Do $ Br (Name "foo") []
             ),
            BasicBlock (Name "foo") [] (
              Do $ Ret Nothing []
             )
           ]
         }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0() {
       entry:
         br label %foo

       foo:                                              ; preds = %0
         ret void
       }|]
     ), (
       "condbr",
       Module "<string>" "<string>" Nothing Nothing [
        GlobalDefinition $ functionDefaults {
          G.returnType = VoidType,
          G.name = UnName 0,
          G.basicBlocks = [
            BasicBlock (Name "bar") [] (
              Do $ CondBr (ConstantOperand (C.Int 1 1)) (Name "foo") (Name "bar") []
             ),
            BasicBlock (Name "foo") [] (
              Do $ Ret Nothing []
             )
           ]
          }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0() {
       bar:
         br i1 true, label %foo, label %bar

       foo:                                              ; preds = %bar
         ret void
       }|]
     ), (
       "switch",
       Module "<string>" "<string>" Nothing Nothing [
         GlobalDefinition $ functionDefaults {
           G.returnType = VoidType,
           G.name = UnName 0,
           G.basicBlocks = [
             BasicBlock (Name "entry") [] (
               Do $ Switch {
                 operand0' = ConstantOperand (C.Int 16 2),
                 defaultDest = Name "foo",
                 dests = [
                  (C.Int 16 0, Name "entry"),
                  (C.Int 16 2, Name "foo"),
                  (C.Int 16 3, Name "entry")
                 ],
                 metadata' = []
              }
             ),
             BasicBlock (Name "foo") [] (
               Do $ Ret Nothing []
              )
            ]
          }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0() {
       entry:
         switch i16 2, label %foo [
           i16 0, label %entry
           i16 2, label %foo
           i16 3, label %entry
         ]

       foo:
         ret void
       }|]
     ), (
       "indirectbr",
       Module "<string>" "<string>" Nothing Nothing [
        GlobalDefinition $ globalVariableDefaults {
          G.name = UnName 0,
          G.type' = PointerType (IntegerType 8) (AddrSpace 0),
          G.initializer = Just (C.BlockAddress (Name "foo") (Name "end"))
        },
        GlobalDefinition $ functionDefaults {
          G.returnType = VoidType,
          G.name = Name "foo",
          G.basicBlocks = [
            BasicBlock (Name "entry") [
              UnName 0 := Load {
                       volatile = False,
                       address = ConstantOperand (C.GlobalReference (ptr (ptr i8)) (UnName 0)),
                       maybeAtomicity = Nothing,
                       alignment = 0,
                       metadata = []
                     }
            ] (
              Do $ IndirectBr {
                operand0' = LocalReference (ptr i8) (UnName 0),
                possibleDests = [Name "end"],
                metadata' = []
             }
            ),
            BasicBlock (Name "end") [] (
              Do $ Ret Nothing []
             )
           ]
         }
        ],
--       \  indirectbr i8* null, [label %foo]\n\
       [llmod|; ModuleID = '<string>'

       @0 = global i8* blockaddress(@foo, %end)

       define void @foo() {
       entry:
         %0 = load i8** @0
         indirectbr i8* %0, [label %end]

       end:
         ret void
       }|]
     ), (
       "invoke",
       Module "<string>" "<string>" Nothing Nothing [
        GlobalDefinition $ functionDefaults {
          G.returnType = VoidType,
          G.name = UnName 0,
          G.parameters = ([
            Parameter (IntegerType 32) (Name "a") [],
            Parameter (IntegerType 16) (Name "b") []
           ], False),
          G.basicBlocks = [
            BasicBlock (Name "entry") [] (
              Do $ Invoke {
               callingConvention' = CC.C,
               returnAttributes' = [],
               function' = Right (ConstantOperand (C.GlobalReference (ptr (FunctionType void [i32, i16] False)) (UnName 0))),
               arguments' = [
                (ConstantOperand (C.Int 32 4), []),
                (ConstantOperand (C.Int 16 8), [])
               ],
               functionAttributes' = [],
               returnDest = Name "foo",
               exceptionDest = Name "bar",
               metadata' = []
              }
             ),
            BasicBlock (Name "foo") [] (
              Do $ Ret Nothing []
             ),
            BasicBlock (Name "bar") [
             UnName 0 := LandingPad {
               type' = StructureType False [
                  PointerType (IntegerType 8) (AddrSpace 0),
                  IntegerType 32
                 ],
               cleanup = True,
               clauses = [Catch (C.Null (PointerType (IntegerType 8) (AddrSpace 0)))],
               metadata = []
             }
             ] (
              Do $ Ret Nothing []
             )
           ]
         }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0(i32 %a, i16 %b) {
       entry:
         invoke void @0(i32 4, i16 8)
                 to label %foo unwind label %bar

       foo:
         ret void

       bar:
         %0 = landingpad { i8*, i32 }
                 cleanup
                 catch i8* null
         ret void
       }|]
     ), (
       "resume",
       Module "<string>" "<string>" Nothing Nothing [
         GlobalDefinition $ functionDefaults {
           G.returnType = VoidType,
           G.name = UnName 0,
           G.basicBlocks = [
             BasicBlock (Name "entry") [] (
               Do $ Resume (ConstantOperand (C.Int 32 1)) []
              )
            ]
          }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0() {
       entry:
         resume i32 1
       }|]
     ), (
       "unreachable",
       Module "<string>" "<string>" Nothing Nothing [
        GlobalDefinition $ functionDefaults {
          G.returnType = VoidType,
          G.name = UnName 0,
          G.basicBlocks = [
            BasicBlock (Name "entry") [] (
              Do $ Unreachable []
             )
           ]
         }
        ],
       [llmod|; ModuleID = '<string>'

       define void @0() {
       entry:
         unreachable
       }|]
     )
    ]
   ]
 ]
