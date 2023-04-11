; ModuleID = 'demo.c'
source_filename = "demo.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !7
@str = private unnamed_addr constant [13 x i8] c"double free!\00", align 1
@str.4 = private unnamed_addr constant [30 x i8] c"too small, try one more time!\00", align 1

; Function Attrs: nofree noinline nounwind uwtable
define dso_local i32 @usep() local_unnamed_addr #0 !dbg !34 {
  %1 = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %1) #6, !dbg !42
  call void @llvm.dbg.value(metadata ptr %1, metadata !38, metadata !DIExpression(DW_OP_deref)), !dbg !43
  %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %1), !dbg !44
  %3 = load i32, ptr %1, align 4, !dbg !45, !tbaa !47
  call void @llvm.dbg.value(metadata i32 %3, metadata !38, metadata !DIExpression()), !dbg !43
  %4 = icmp slt i32 %3, 10, !dbg !51
  br i1 %4, label %5, label %8, !dbg !52

5:                                                ; preds = %0
  %6 = call i32 @puts(ptr nonnull @str.4), !dbg !53
  call void @llvm.dbg.value(metadata ptr %1, metadata !38, metadata !DIExpression(DW_OP_deref)), !dbg !43
  %7 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %1), !dbg !55
  br label %21, !dbg !56

8:                                                ; preds = %0
  %9 = zext i32 %3 to i64
  %10 = call noalias ptr @malloc(i64 noundef %9) #7, !dbg !57
  call void @llvm.dbg.value(metadata ptr %10, metadata !39, metadata !DIExpression()), !dbg !43
  call void @llvm.dbg.value(metadata i32 0, metadata !40, metadata !DIExpression()), !dbg !58
  call void @llvm.dbg.value(metadata i32 %3, metadata !38, metadata !DIExpression()), !dbg !43
  br label %13, !dbg !59

11:                                               ; preds = %13
  %12 = call i32 @puts(ptr nonnull @str), !dbg !60
  br label %21

13:                                               ; preds = %8, %13
  %14 = phi i64 [ 0, %8 ], [ %17, %13 ]
  call void @llvm.dbg.value(metadata i64 %14, metadata !40, metadata !DIExpression()), !dbg !58
  %15 = getelementptr inbounds i32, ptr %10, i64 %14, !dbg !61
  %16 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %15), !dbg !63
  %17 = add nuw nsw i64 %14, 1, !dbg !64
  call void @llvm.dbg.value(metadata i64 %17, metadata !40, metadata !DIExpression()), !dbg !58
  %18 = load i32, ptr %1, align 4, !dbg !65, !tbaa !47
  call void @llvm.dbg.value(metadata i32 %18, metadata !38, metadata !DIExpression()), !dbg !43
  %19 = sext i32 %18 to i64, !dbg !66
  %20 = icmp slt i64 %17, %19, !dbg !66
  br i1 %20, label %13, label %11, !dbg !59, !llvm.loop !67

21:                                               ; preds = %11, %5
  %22 = phi i32 [ -2, %5 ], [ -1, %11 ], !dbg !43
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %1) #6, !dbg !70
  ret i32 %22, !dbg !70
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(ptr nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #3

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nofree noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 !dbg !71 {
  %1 = tail call i32 @usep(), !dbg !73, !range !74
  %2 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.3, i32 noundef %1), !dbg !75
  ret i32 0, !dbg !76
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #4

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #5

attributes #0 = { nofree noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #2 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #5 = { nofree nounwind }
attributes #6 = { nounwind }
attributes #7 = { nounwind allocsize(0) }

!llvm.dbg.cu = !{!12}
!llvm.module.flags = !{!27, !28, !29, !30, !31, !32}
!llvm.ident = !{!33}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 6, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "demo.c", directory: "/home/secondst/code/MyAnalysis/demo", checksumkind: CSK_MD5, checksum: "486997af22b653fc379739fc8eaf0b99")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 20, type: !9, isLocal: true, isDefinition: true)
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !10)
!10 = !{!11}
!11 = !DISubrange(count: 4)
!12 = distinct !DICompileUnit(language: DW_LANG_C99, file: !2, producer: "Ubuntu clang version 15.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !13, globals: !16, splitDebugInlining: false, nameTableKind: None)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!15 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!16 = !{!0, !17, !22, !7}
!17 = !DIGlobalVariableExpression(var: !18, expr: !DIExpression())
!18 = distinct !DIGlobalVariable(scope: null, file: !2, line: 8, type: !19, isLocal: true, isDefinition: true)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 248, elements: !20)
!20 = !{!21}
!21 = !DISubrange(count: 31)
!22 = !DIGlobalVariableExpression(var: !23, expr: !DIExpression())
!23 = distinct !DIGlobalVariable(scope: null, file: !2, line: 15, type: !24, isLocal: true, isDefinition: true)
!24 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 112, elements: !25)
!25 = !{!26}
!26 = !DISubrange(count: 14)
!27 = !{i32 7, !"Dwarf Version", i32 5}
!28 = !{i32 2, !"Debug Info Version", i32 3}
!29 = !{i32 1, !"wchar_size", i32 4}
!30 = !{i32 7, !"PIC Level", i32 2}
!31 = !{i32 7, !"PIE Level", i32 2}
!32 = !{i32 7, !"uwtable", i32 2}
!33 = !{!"Ubuntu clang version 15.0.6"}
!34 = distinct !DISubprogram(name: "usep", scope: !2, file: !2, line: 4, type: !35, scopeLine: 4, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !37)
!35 = !DISubroutineType(types: !36)
!36 = !{!15}
!37 = !{!38, !39, !40}
!38 = !DILocalVariable(name: "n", scope: !34, file: !2, line: 5, type: !15)
!39 = !DILocalVariable(name: "p1", scope: !34, file: !2, line: 12, type: !14)
!40 = !DILocalVariable(name: "i", scope: !41, file: !2, line: 13, type: !15)
!41 = distinct !DILexicalBlock(scope: !34, file: !2, line: 13, column: 3)
!42 = !DILocation(line: 5, column: 3, scope: !34)
!43 = !DILocation(line: 0, scope: !34)
!44 = !DILocation(line: 6, column: 3, scope: !34)
!45 = !DILocation(line: 7, column: 7, scope: !46)
!46 = distinct !DILexicalBlock(scope: !34, file: !2, line: 7, column: 7)
!47 = !{!48, !48, i64 0}
!48 = !{!"int", !49, i64 0}
!49 = !{!"omnipotent char", !50, i64 0}
!50 = !{!"Simple C/C++ TBAA"}
!51 = !DILocation(line: 7, column: 9, scope: !46)
!52 = !DILocation(line: 7, column: 7, scope: !34)
!53 = !DILocation(line: 8, column: 5, scope: !54)
!54 = distinct !DILexicalBlock(scope: !46, file: !2, line: 7, column: 15)
!55 = !DILocation(line: 9, column: 5, scope: !54)
!56 = !DILocation(line: 10, column: 5, scope: !54)
!57 = !DILocation(line: 12, column: 20, scope: !34)
!58 = !DILocation(line: 0, scope: !41)
!59 = !DILocation(line: 13, column: 3, scope: !41)
!60 = !DILocation(line: 15, column: 3, scope: !34)
!61 = !DILocation(line: 14, column: 18, scope: !62)
!62 = distinct !DILexicalBlock(scope: !41, file: !2, line: 13, column: 3)
!63 = !DILocation(line: 14, column: 5, scope: !62)
!64 = !DILocation(line: 13, column: 27, scope: !62)
!65 = !DILocation(line: 13, column: 23, scope: !62)
!66 = !DILocation(line: 13, column: 21, scope: !62)
!67 = distinct !{!67, !59, !68, !69}
!68 = !DILocation(line: 14, column: 23, scope: !41)
!69 = !{!"llvm.loop.mustprogress"}
!70 = !DILocation(line: 17, column: 1, scope: !34)
!71 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 19, type: !35, scopeLine: 19, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !72)
!72 = !{}
!73 = !DILocation(line: 20, column: 18, scope: !71)
!74 = !{i32 -2, i32 0}
!75 = !DILocation(line: 20, column: 3, scope: !71)
!76 = !DILocation(line: 21, column: 3, scope: !71)
