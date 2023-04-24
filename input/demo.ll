; ModuleID = 'demo.c'
source_filename = "demo.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0
@.str.2 = private unnamed_addr constant [4 x i8] c"%p\0A\00", align 1, !dbg !7
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !12
@str = private unnamed_addr constant [30 x i8] c"too small, try one more time!\00", align 1

; Function Attrs: mustprogress noinline nounwind willreturn uwtable
define dso_local void @test(ptr nocapture noundef %p1, i32 %x) local_unnamed_addr #0 !dbg !31 {
entry:
  call void @llvm.dbg.value(metadata ptr %p1, metadata !35, metadata !DIExpression()), !dbg !37
  call void @llvm.dbg.value(metadata i32 poison, metadata !36, metadata !DIExpression()), !dbg !37
  tail call void @free(ptr noundef %p1) #8, !dbg !38
  ret void, !dbg !39
}

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free")
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @usep() local_unnamed_addr #2 !dbg !40 {
entry:
  %n = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %n) #8, !dbg !48
  call void @llvm.dbg.value(metadata ptr %n, metadata !44, metadata !DIExpression(DW_OP_deref)), !dbg !49
  %call = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %n), !dbg !50
  %0 = load i32, ptr %n, align 4, !dbg !51, !tbaa !53
  call void @llvm.dbg.value(metadata i32 %0, metadata !44, metadata !DIExpression()), !dbg !49
  %cmp = icmp slt i32 %0, 10, !dbg !57
  br i1 %cmp, label %if.then, label %for.body.preheader, !dbg !58

if.then:                                          ; preds = %entry
  %puts = call i32 @puts(ptr nonnull @str), !dbg !59
  call void @llvm.dbg.value(metadata ptr %n, metadata !44, metadata !DIExpression(DW_OP_deref)), !dbg !49
  %call2 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %n), !dbg !61
  br label %cleanup, !dbg !62

for.body.preheader:                               ; preds = %entry
  %conv = zext i32 %0 to i64
  %call3 = call noalias ptr @malloc(i64 noundef %conv) #9, !dbg !63
  call void @llvm.dbg.value(metadata ptr %call3, metadata !45, metadata !DIExpression()), !dbg !49
  call void @llvm.dbg.value(metadata i32 0, metadata !46, metadata !DIExpression()), !dbg !64
  call void @llvm.dbg.value(metadata i32 %0, metadata !44, metadata !DIExpression()), !dbg !49
  br label %for.body, !dbg !65

for.cond.cleanup:                                 ; preds = %for.body
  call void @free(ptr noundef %call3) #8, !dbg !66
  %call7 = call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.2, ptr noundef %call3), !dbg !67
  br label %cleanup

for.body:                                         ; preds = %for.body.preheader, %for.body
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !46, metadata !DIExpression()), !dbg !64
  %arrayidx = getelementptr inbounds i32, ptr %call3, i64 %indvars.iv, !dbg !68
  %call6 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %arrayidx), !dbg !70
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !71
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next, metadata !46, metadata !DIExpression()), !dbg !64
  %1 = load i32, ptr %n, align 4, !dbg !72, !tbaa !53
  call void @llvm.dbg.value(metadata i32 %1, metadata !44, metadata !DIExpression()), !dbg !49
  %2 = sext i32 %1 to i64, !dbg !73
  %cmp4 = icmp slt i64 %indvars.iv.next, %2, !dbg !73
  br i1 %cmp4, label %for.body, label %for.cond.cleanup, !dbg !65, !llvm.loop !74

cleanup:                                          ; preds = %for.cond.cleanup, %if.then
  %retval.0 = phi i32 [ -2, %if.then ], [ -1, %for.cond.cleanup ], !dbg !49
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %n) #8, !dbg !77
  ret i32 %retval.0, !dbg !77
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #3

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(ptr nocapture noundef readonly, ...) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #4

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #5

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #3

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #2 !dbg !78 {
entry:
  %call = tail call i32 @usep(), !dbg !81, !range !82
  %call1 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.3, i32 noundef %call), !dbg !83
  tail call void @test(ptr noundef undef, i32 poison), !dbg !84
  ret i32 0, !dbg !85
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #6

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #7

attributes #0 = { mustprogress noinline nounwind willreturn uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free") "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #4 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { nofree nounwind }
attributes #8 = { nounwind }
attributes #9 = { nounwind allocsize(0) }

!llvm.dbg.cu = !{!14}
!llvm.module.flags = !{!24, !25, !26, !27, !28, !29}
!llvm.ident = !{!30}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 10, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "demo.c", directory: "/home/secondst/code/MyAnalysis/demo", checksumkind: CSK_MD5, checksum: "23fc8ab8c55e059901d1a206b085fc01")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 20, type: !9, isLocal: true, isDefinition: true)
!9 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !10)
!10 = !{!11}
!11 = !DISubrange(count: 4)
!12 = !DIGlobalVariableExpression(var: !13, expr: !DIExpression())
!13 = distinct !DIGlobalVariable(scope: null, file: !2, line: 25, type: !9, isLocal: true, isDefinition: true)
!14 = distinct !DICompileUnit(language: DW_LANG_C99, file: !2, producer: "Ubuntu clang version 15.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !15, globals: !18, splitDebugInlining: false, nameTableKind: None)
!15 = !{!16}
!16 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !17, size: 64)
!17 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!18 = !{!0, !19, !7, !12}
!19 = !DIGlobalVariableExpression(var: !20, expr: !DIExpression())
!20 = distinct !DIGlobalVariable(scope: null, file: !2, line: 12, type: !21, isLocal: true, isDefinition: true)
!21 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 248, elements: !22)
!22 = !{!23}
!23 = !DISubrange(count: 31)
!24 = !{i32 7, !"Dwarf Version", i32 5}
!25 = !{i32 2, !"Debug Info Version", i32 3}
!26 = !{i32 1, !"wchar_size", i32 4}
!27 = !{i32 7, !"PIC Level", i32 2}
!28 = !{i32 7, !"PIE Level", i32 2}
!29 = !{i32 7, !"uwtable", i32 2}
!30 = !{!"Ubuntu clang version 15.0.6"}
!31 = distinct !DISubprogram(name: "test", scope: !2, file: !2, line: 4, type: !32, scopeLine: 4, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !14, retainedNodes: !34)
!32 = !DISubroutineType(types: !33)
!33 = !{null, !16, !17}
!34 = !{!35, !36}
!35 = !DILocalVariable(name: "p1", arg: 1, scope: !31, file: !2, line: 4, type: !16)
!36 = !DILocalVariable(name: "x", arg: 2, scope: !31, file: !2, line: 4, type: !17)
!37 = !DILocation(line: 0, scope: !31)
!38 = !DILocation(line: 5, column: 5, scope: !31)
!39 = !DILocation(line: 6, column: 1, scope: !31)
!40 = distinct !DISubprogram(name: "usep", scope: !2, file: !2, line: 8, type: !41, scopeLine: 8, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !14, retainedNodes: !43)
!41 = !DISubroutineType(types: !42)
!42 = !{!17}
!43 = !{!44, !45, !46}
!44 = !DILocalVariable(name: "n", scope: !40, file: !2, line: 9, type: !17)
!45 = !DILocalVariable(name: "p1", scope: !40, file: !2, line: 16, type: !16)
!46 = !DILocalVariable(name: "i", scope: !47, file: !2, line: 17, type: !17)
!47 = distinct !DILexicalBlock(scope: !40, file: !2, line: 17, column: 5)
!48 = !DILocation(line: 9, column: 3, scope: !40)
!49 = !DILocation(line: 0, scope: !40)
!50 = !DILocation(line: 10, column: 5, scope: !40)
!51 = !DILocation(line: 11, column: 8, scope: !52)
!52 = distinct !DILexicalBlock(scope: !40, file: !2, line: 11, column: 8)
!53 = !{!54, !54, i64 0}
!54 = !{!"int", !55, i64 0}
!55 = !{!"omnipotent char", !56, i64 0}
!56 = !{!"Simple C/C++ TBAA"}
!57 = !DILocation(line: 11, column: 9, scope: !52)
!58 = !DILocation(line: 11, column: 8, scope: !40)
!59 = !DILocation(line: 12, column: 9, scope: !60)
!60 = distinct !DILexicalBlock(scope: !52, file: !2, line: 11, column: 13)
!61 = !DILocation(line: 13, column: 9, scope: !60)
!62 = !DILocation(line: 14, column: 9, scope: !60)
!63 = !DILocation(line: 16, column: 21, scope: !40)
!64 = !DILocation(line: 0, scope: !47)
!65 = !DILocation(line: 17, column: 5, scope: !47)
!66 = !DILocation(line: 19, column: 5, scope: !40)
!67 = !DILocation(line: 20, column: 5, scope: !40)
!68 = !DILocation(line: 18, column: 21, scope: !69)
!69 = distinct !DILexicalBlock(scope: !47, file: !2, line: 17, column: 5)
!70 = !DILocation(line: 18, column: 9, scope: !69)
!71 = !DILocation(line: 17, column: 22, scope: !69)
!72 = !DILocation(line: 17, column: 19, scope: !69)
!73 = !DILocation(line: 17, column: 18, scope: !69)
!74 = distinct !{!74, !65, !75, !76}
!75 = !DILocation(line: 18, column: 26, scope: !47)
!76 = !{!"llvm.loop.mustprogress"}
!77 = !DILocation(line: 22, column: 1, scope: !40)
!78 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 24, type: !41, scopeLine: 24, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !14, retainedNodes: !79)
!79 = !{!80}
!80 = !DILocalVariable(name: "p", scope: !78, file: !2, line: 26, type: !16)
!81 = !DILocation(line: 25, column: 18, scope: !78)
!82 = !{i32 -2, i32 0}
!83 = !DILocation(line: 25, column: 3, scope: !78)
!84 = !DILocation(line: 27, column: 3, scope: !78)
!85 = !DILocation(line: 28, column: 3, scope: !78)
