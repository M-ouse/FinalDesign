; ModuleID = 'demo1.c'
source_filename = "demo1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !7
@str = private unnamed_addr constant [16 x i8] c"no double free!\00", align 1
@str.4 = private unnamed_addr constant [30 x i8] c"too small, try one more time!\00", align 1

; Function Attrs: nofree noinline nounwind uwtable
define dso_local void @test(ptr nocapture readnone %0) local_unnamed_addr #0 !dbg !34 {
  call void @llvm.dbg.value(metadata ptr poison, metadata !38, metadata !DIExpression()), !dbg !39
  %2 = tail call noalias dereferenceable_or_null(10) ptr @malloc(i64 noundef 10) #8, !dbg !40
  call void @llvm.dbg.value(metadata ptr %2, metadata !38, metadata !DIExpression()), !dbg !39
  %3 = tail call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %2), !dbg !41
  ret void, !dbg !42
}

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(ptr nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @usep() local_unnamed_addr #3 !dbg !43 {
  %1 = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %1) #9, !dbg !51
  call void @llvm.dbg.value(metadata ptr %1, metadata !47, metadata !DIExpression(DW_OP_deref)), !dbg !52
  %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %1), !dbg !53
  %3 = load i32, ptr %1, align 4, !dbg !54, !tbaa !56
  call void @llvm.dbg.value(metadata i32 %3, metadata !47, metadata !DIExpression()), !dbg !52
  %4 = icmp slt i32 %3, 10, !dbg !60
  br i1 %4, label %5, label %8, !dbg !61

5:                                                ; preds = %0
  %6 = call i32 @puts(ptr nonnull @str.4), !dbg !62
  call void @llvm.dbg.value(metadata ptr %1, metadata !47, metadata !DIExpression(DW_OP_deref)), !dbg !52
  %7 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %1), !dbg !64
  br label %21, !dbg !65

8:                                                ; preds = %0
  %9 = zext i32 %3 to i64
  %10 = call noalias ptr @malloc(i64 noundef %9) #8, !dbg !66
  call void @llvm.dbg.value(metadata ptr %10, metadata !48, metadata !DIExpression()), !dbg !52
  call void @llvm.dbg.value(metadata i32 0, metadata !49, metadata !DIExpression()), !dbg !67
  call void @llvm.dbg.value(metadata i32 %3, metadata !47, metadata !DIExpression()), !dbg !52
  br label %13, !dbg !68

11:                                               ; preds = %13
  call void @free(ptr noundef %10) #9, !dbg !69
  %12 = call i32 @puts(ptr nonnull @str), !dbg !70
  br label %21

13:                                               ; preds = %8, %13
  %14 = phi i64 [ 0, %8 ], [ %17, %13 ]
  call void @llvm.dbg.value(metadata i64 %14, metadata !49, metadata !DIExpression()), !dbg !67
  %15 = getelementptr inbounds i32, ptr %10, i64 %14, !dbg !71
  %16 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %15), !dbg !73
  %17 = add nuw nsw i64 %14, 1, !dbg !74
  call void @llvm.dbg.value(metadata i64 %17, metadata !49, metadata !DIExpression()), !dbg !67
  %18 = load i32, ptr %1, align 4, !dbg !75, !tbaa !56
  call void @llvm.dbg.value(metadata i32 %18, metadata !47, metadata !DIExpression()), !dbg !52
  %19 = sext i32 %18 to i64, !dbg !76
  %20 = icmp slt i64 %17, %19, !dbg !76
  br i1 %20, label %13, label %11, !dbg !68, !llvm.loop !77

21:                                               ; preds = %11, %5
  %22 = phi i32 [ -2, %5 ], [ -1, %11 ], !dbg !52
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %1) #9, !dbg !80
  ret i32 %22, !dbg !80
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #4

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free")
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #5

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #3 !dbg !81 {
  %1 = tail call i32 @usep(), !dbg !84, !range !85
  %2 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.3, i32 noundef %1), !dbg !86
  tail call void @test(ptr poison), !dbg !87
  ret i32 0, !dbg !88
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #6

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #7

attributes #0 = { nofree noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #5 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free") "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { nofree nounwind }
attributes #8 = { nounwind allocsize(0) }
attributes #9 = { nounwind }

!llvm.dbg.cu = !{!12}
!llvm.module.flags = !{!27, !28, !29, !30, !31, !32}
!llvm.ident = !{!33}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 6, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "demo1.c", directory: "/home/secondst/code/MyAnalysis/demo", checksumkind: CSK_MD5, checksum: "abc562a24d3868c71417cbf6b1a2a06c")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 26, type: !9, isLocal: true, isDefinition: true)
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !10)
!10 = !{!11}
!11 = !DISubrange(count: 4)
!12 = distinct !DICompileUnit(language: DW_LANG_C99, file: !2, producer: "Ubuntu clang version 15.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !13, globals: !16, splitDebugInlining: false, nameTableKind: None)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!15 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!16 = !{!0, !17, !22, !7}
!17 = !DIGlobalVariableExpression(var: !18, expr: !DIExpression())
!18 = distinct !DIGlobalVariable(scope: null, file: !2, line: 13, type: !19, isLocal: true, isDefinition: true)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 248, elements: !20)
!20 = !{!21}
!21 = !DISubrange(count: 31)
!22 = !DIGlobalVariableExpression(var: !23, expr: !DIExpression())
!23 = distinct !DIGlobalVariable(scope: null, file: !2, line: 21, type: !24, isLocal: true, isDefinition: true)
!24 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 136, elements: !25)
!25 = !{!26}
!26 = !DISubrange(count: 17)
!27 = !{i32 7, !"Dwarf Version", i32 5}
!28 = !{i32 2, !"Debug Info Version", i32 3}
!29 = !{i32 1, !"wchar_size", i32 4}
!30 = !{i32 7, !"PIC Level", i32 2}
!31 = !{i32 7, !"PIE Level", i32 2}
!32 = !{i32 7, !"uwtable", i32 2}
!33 = !{!"Ubuntu clang version 15.0.6"}
!34 = distinct !DISubprogram(name: "test", scope: !2, file: !2, line: 4, type: !35, scopeLine: 4, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !37)
!35 = !DISubroutineType(types: !36)
!36 = !{null, !14}
!37 = !{!38}
!38 = !DILocalVariable(name: "p1", arg: 1, scope: !34, file: !2, line: 4, type: !14)
!39 = !DILocation(line: 0, scope: !34)
!40 = !DILocation(line: 5, column: 16, scope: !34)
!41 = !DILocation(line: 6, column: 5, scope: !34)
!42 = !DILocation(line: 7, column: 1, scope: !34)
!43 = distinct !DISubprogram(name: "usep", scope: !2, file: !2, line: 9, type: !44, scopeLine: 9, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !46)
!44 = !DISubroutineType(types: !45)
!45 = !{!15}
!46 = !{!47, !48, !49}
!47 = !DILocalVariable(name: "n", scope: !43, file: !2, line: 10, type: !15)
!48 = !DILocalVariable(name: "p1", scope: !43, file: !2, line: 17, type: !14)
!49 = !DILocalVariable(name: "i", scope: !50, file: !2, line: 18, type: !15)
!50 = distinct !DILexicalBlock(scope: !43, file: !2, line: 18, column: 5)
!51 = !DILocation(line: 10, column: 5, scope: !43)
!52 = !DILocation(line: 0, scope: !43)
!53 = !DILocation(line: 11, column: 5, scope: !43)
!54 = !DILocation(line: 12, column: 8, scope: !55)
!55 = distinct !DILexicalBlock(scope: !43, file: !2, line: 12, column: 8)
!56 = !{!57, !57, i64 0}
!57 = !{!"int", !58, i64 0}
!58 = !{!"omnipotent char", !59, i64 0}
!59 = !{!"Simple C/C++ TBAA"}
!60 = !DILocation(line: 12, column: 9, scope: !55)
!61 = !DILocation(line: 12, column: 8, scope: !43)
!62 = !DILocation(line: 13, column: 9, scope: !63)
!63 = distinct !DILexicalBlock(scope: !55, file: !2, line: 12, column: 13)
!64 = !DILocation(line: 14, column: 9, scope: !63)
!65 = !DILocation(line: 15, column: 9, scope: !63)
!66 = !DILocation(line: 17, column: 21, scope: !43)
!67 = !DILocation(line: 0, scope: !50)
!68 = !DILocation(line: 18, column: 5, scope: !50)
!69 = !DILocation(line: 20, column: 5, scope: !43)
!70 = !DILocation(line: 21, column: 5, scope: !43)
!71 = !DILocation(line: 19, column: 21, scope: !72)
!72 = distinct !DILexicalBlock(scope: !50, file: !2, line: 18, column: 5)
!73 = !DILocation(line: 19, column: 9, scope: !72)
!74 = !DILocation(line: 18, column: 22, scope: !72)
!75 = !DILocation(line: 18, column: 19, scope: !72)
!76 = !DILocation(line: 18, column: 18, scope: !72)
!77 = distinct !{!77, !68, !78, !79}
!78 = !DILocation(line: 19, column: 26, scope: !50)
!79 = !{!"llvm.loop.mustprogress"}
!80 = !DILocation(line: 23, column: 1, scope: !43)
!81 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 25, type: !44, scopeLine: 25, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !82)
!82 = !{!83}
!83 = !DILocalVariable(name: "p", scope: !81, file: !2, line: 27, type: !14)
!84 = !DILocation(line: 26, column: 19, scope: !81)
!85 = !{i32 -2, i32 0}
!86 = !DILocation(line: 26, column: 5, scope: !81)
!87 = !DILocation(line: 28, column: 5, scope: !81)
!88 = !DILocation(line: 30, column: 5, scope: !81)
