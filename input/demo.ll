; ModuleID = 'demo.c'
source_filename = "demo.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !7
@str = private unnamed_addr constant [13 x i8] c"double free!\00", align 1
@str.4 = private unnamed_addr constant [30 x i8] c"too small, try one more time!\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local void @test(ptr nocapture readnone %p1, i32 noundef %x) local_unnamed_addr #0 !dbg !34 {
entry:
  call void @llvm.dbg.value(metadata ptr poison, metadata !38, metadata !DIExpression()), !dbg !42
  call void @llvm.dbg.value(metadata i32 %x, metadata !39, metadata !DIExpression()), !dbg !42
  %call = tail call noalias dereferenceable_or_null(10) ptr @malloc(i64 noundef 10) #8, !dbg !43
  call void @llvm.dbg.value(metadata ptr %call, metadata !38, metadata !DIExpression()), !dbg !42
  %call1 = tail call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %call), !dbg !44
  call void @llvm.dbg.value(metadata i32 %call1, metadata !40, metadata !DIExpression()), !dbg !42
  tail call void @free(ptr noundef %call) #9, !dbg !45
  %call2 = tail call noalias dereferenceable_or_null(20) ptr @malloc(i64 noundef 20) #8, !dbg !46
  call void @llvm.dbg.value(metadata ptr %call2, metadata !41, metadata !DIExpression()), !dbg !42
  %idxprom = sext i32 %x to i64, !dbg !47
  %arrayidx = getelementptr inbounds i32, ptr %call2, i64 %idxprom, !dbg !47
  %call3 = tail call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %arrayidx), !dbg !48
  tail call void @free(ptr noundef %call2) #9, !dbg !49
  ret void, !dbg !50
}

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #1

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(ptr nocapture noundef readonly, ...) local_unnamed_addr #3

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free")
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @usep() local_unnamed_addr #0 !dbg !51 {
entry:
  %n = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %n) #9, !dbg !59
  call void @llvm.dbg.value(metadata ptr %n, metadata !55, metadata !DIExpression(DW_OP_deref)), !dbg !60
  %call = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %n), !dbg !61
  %0 = load i32, ptr %n, align 4, !dbg !62, !tbaa !64
  call void @llvm.dbg.value(metadata i32 %0, metadata !55, metadata !DIExpression()), !dbg !60
  %cmp = icmp slt i32 %0, 10, !dbg !68
  br i1 %cmp, label %if.then, label %for.body.preheader, !dbg !69

if.then:                                          ; preds = %entry
  %puts11 = call i32 @puts(ptr nonnull @str.4), !dbg !70
  call void @llvm.dbg.value(metadata ptr %n, metadata !55, metadata !DIExpression(DW_OP_deref)), !dbg !60
  %call2 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %n), !dbg !72
  br label %cleanup, !dbg !73

for.body.preheader:                               ; preds = %entry
  %conv = zext i32 %0 to i64
  %call3 = call noalias ptr @calloc(i64 noundef %conv, i64 noundef 4) #10, !dbg !74
  call void @llvm.dbg.value(metadata ptr %call3, metadata !56, metadata !DIExpression()), !dbg !60
  call void @llvm.dbg.value(metadata i32 0, metadata !57, metadata !DIExpression()), !dbg !75
  call void @llvm.dbg.value(metadata i32 %0, metadata !55, metadata !DIExpression()), !dbg !60
  br label %for.body, !dbg !76

for.cond.cleanup:                                 ; preds = %for.body
  call void @free(ptr noundef %call3) #9, !dbg !77
  %puts = call i32 @puts(ptr nonnull @str), !dbg !78
  br label %cleanup

for.body:                                         ; preds = %for.body.preheader, %for.body
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !57, metadata !DIExpression()), !dbg !75
  %arrayidx = getelementptr inbounds i32, ptr %call3, i64 %indvars.iv, !dbg !79
  %call6 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %arrayidx), !dbg !81
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !82
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next, metadata !57, metadata !DIExpression()), !dbg !75
  %1 = load i32, ptr %n, align 4, !dbg !83, !tbaa !64
  call void @llvm.dbg.value(metadata i32 %1, metadata !55, metadata !DIExpression()), !dbg !60
  %2 = sext i32 %1 to i64, !dbg !84
  %cmp4 = icmp slt i64 %indvars.iv.next, %2, !dbg !84
  br i1 %cmp4, label %for.body, label %for.cond.cleanup, !dbg !76, !llvm.loop !85

cleanup:                                          ; preds = %for.cond.cleanup, %if.then
  %retval.0 = phi i32 [ -2, %if.then ], [ -1, %for.cond.cleanup ], !dbg !60
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %n) #9, !dbg !88
  ret i32 %retval.0, !dbg !88
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #3

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1)
declare noalias noundef ptr @calloc(i64 noundef, i64 noundef) local_unnamed_addr #5

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 !dbg !89 {
entry:
  %call = tail call i32 @usep(), !dbg !92, !range !93
  %call1 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.3, i32 noundef %call), !dbg !94
  tail call void @test(ptr poison, i32 noundef 15), !dbg !95
  ret i32 0, !dbg !96
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #6

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #7

attributes #0 = { noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #3 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free") "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { nofree nounwind }
attributes #8 = { nounwind allocsize(0) }
attributes #9 = { nounwind }
attributes #10 = { nounwind allocsize(0,1) }

!llvm.dbg.cu = !{!12}
!llvm.module.flags = !{!27, !28, !29, !30, !31, !32}
!llvm.ident = !{!33}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 6, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "demo.c", directory: "/home/secondst/code/MyAnalysis/demo", checksumkind: CSK_MD5, checksum: "fcc7a5ec53aed8e7d908cc893db781f4")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 31, type: !9, isLocal: true, isDefinition: true)
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !10)
!10 = !{!11}
!11 = !DISubrange(count: 4)
!12 = distinct !DICompileUnit(language: DW_LANG_C99, file: !2, producer: "Ubuntu clang version 15.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !13, globals: !16, splitDebugInlining: false, nameTableKind: None)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!15 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!16 = !{!0, !17, !22, !7}
!17 = !DIGlobalVariableExpression(var: !18, expr: !DIExpression())
!18 = distinct !DIGlobalVariable(scope: null, file: !2, line: 18, type: !19, isLocal: true, isDefinition: true)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 248, elements: !20)
!20 = !{!21}
!21 = !DISubrange(count: 31)
!22 = !DIGlobalVariableExpression(var: !23, expr: !DIExpression())
!23 = distinct !DIGlobalVariable(scope: null, file: !2, line: 26, type: !24, isLocal: true, isDefinition: true)
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
!34 = distinct !DISubprogram(name: "test", scope: !2, file: !2, line: 4, type: !35, scopeLine: 4, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !37)
!35 = !DISubroutineType(types: !36)
!36 = !{null, !14, !15}
!37 = !{!38, !39, !40, !41}
!38 = !DILocalVariable(name: "p1", arg: 1, scope: !34, file: !2, line: 4, type: !14)
!39 = !DILocalVariable(name: "x", arg: 2, scope: !34, file: !2, line: 4, type: !15)
!40 = !DILocalVariable(name: "n", scope: !34, file: !2, line: 6, type: !15)
!41 = !DILocalVariable(name: "p2", scope: !34, file: !2, line: 9, type: !14)
!42 = !DILocation(line: 0, scope: !34)
!43 = !DILocation(line: 5, column: 16, scope: !34)
!44 = !DILocation(line: 6, column: 13, scope: !34)
!45 = !DILocation(line: 7, column: 5, scope: !34)
!46 = !DILocation(line: 9, column: 21, scope: !34)
!47 = !DILocation(line: 10, column: 17, scope: !34)
!48 = !DILocation(line: 10, column: 5, scope: !34)
!49 = !DILocation(line: 11, column: 5, scope: !34)
!50 = !DILocation(line: 12, column: 1, scope: !34)
!51 = distinct !DISubprogram(name: "usep", scope: !2, file: !2, line: 14, type: !52, scopeLine: 14, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !54)
!52 = !DISubroutineType(types: !53)
!53 = !{!15}
!54 = !{!55, !56, !57}
!55 = !DILocalVariable(name: "n", scope: !51, file: !2, line: 15, type: !15)
!56 = !DILocalVariable(name: "p1", scope: !51, file: !2, line: 22, type: !14)
!57 = !DILocalVariable(name: "i", scope: !58, file: !2, line: 23, type: !15)
!58 = distinct !DILexicalBlock(scope: !51, file: !2, line: 23, column: 3)
!59 = !DILocation(line: 15, column: 3, scope: !51)
!60 = !DILocation(line: 0, scope: !51)
!61 = !DILocation(line: 16, column: 3, scope: !51)
!62 = !DILocation(line: 17, column: 7, scope: !63)
!63 = distinct !DILexicalBlock(scope: !51, file: !2, line: 17, column: 7)
!64 = !{!65, !65, i64 0}
!65 = !{!"int", !66, i64 0}
!66 = !{!"omnipotent char", !67, i64 0}
!67 = !{!"Simple C/C++ TBAA"}
!68 = !DILocation(line: 17, column: 9, scope: !63)
!69 = !DILocation(line: 17, column: 7, scope: !51)
!70 = !DILocation(line: 18, column: 5, scope: !71)
!71 = distinct !DILexicalBlock(scope: !63, file: !2, line: 17, column: 15)
!72 = !DILocation(line: 19, column: 5, scope: !71)
!73 = !DILocation(line: 20, column: 5, scope: !71)
!74 = !DILocation(line: 22, column: 20, scope: !51)
!75 = !DILocation(line: 0, scope: !58)
!76 = !DILocation(line: 23, column: 3, scope: !58)
!77 = !DILocation(line: 25, column: 3, scope: !51)
!78 = !DILocation(line: 26, column: 3, scope: !51)
!79 = !DILocation(line: 24, column: 18, scope: !80)
!80 = distinct !DILexicalBlock(scope: !58, file: !2, line: 23, column: 3)
!81 = !DILocation(line: 24, column: 5, scope: !80)
!82 = !DILocation(line: 23, column: 27, scope: !80)
!83 = !DILocation(line: 23, column: 23, scope: !80)
!84 = !DILocation(line: 23, column: 21, scope: !80)
!85 = distinct !{!85, !76, !86, !87}
!86 = !DILocation(line: 24, column: 23, scope: !58)
!87 = !{!"llvm.loop.mustprogress"}
!88 = !DILocation(line: 28, column: 1, scope: !51)
!89 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 30, type: !52, scopeLine: 30, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !90)
!90 = !{!91}
!91 = !DILocalVariable(name: "p", scope: !89, file: !2, line: 32, type: !14)
!92 = !DILocation(line: 31, column: 18, scope: !89)
!93 = !{i32 -2, i32 0}
!94 = !DILocation(line: 31, column: 3, scope: !89)
!95 = !DILocation(line: 33, column: 3, scope: !89)
!96 = !DILocation(line: 34, column: 3, scope: !89)
