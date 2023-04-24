; ModuleID = 'demo1.c'
source_filename = "demo1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !7
@str = private unnamed_addr constant [13 x i8] c"double free!\00", align 1
@str.4 = private unnamed_addr constant [30 x i8] c"too small, try one more time!\00", align 1

; Function Attrs: argmemonly mustprogress nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
define dso_local void @test(ptr nocapture noundef writeonly %p1) local_unnamed_addr #0 !dbg !34 {
entry:
  call void @llvm.dbg.value(metadata ptr %p1, metadata !38, metadata !DIExpression()), !dbg !39
  %arrayidx = getelementptr inbounds i32, ptr %p1, i64 100, !dbg !40
  store i32 10, ptr %arrayidx, align 4, !dbg !41, !tbaa !42
  ret void, !dbg !46
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @usep() local_unnamed_addr #1 !dbg !47 {
entry:
  %n = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %n) #8, !dbg !55
  call void @llvm.dbg.value(metadata ptr %n, metadata !51, metadata !DIExpression(DW_OP_deref)), !dbg !56
  %call = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %n), !dbg !57
  %0 = load i32, ptr %n, align 4, !dbg !58, !tbaa !42
  call void @llvm.dbg.value(metadata i32 %0, metadata !51, metadata !DIExpression()), !dbg !56
  %cmp = icmp slt i32 %0, 10, !dbg !60
  br i1 %cmp, label %if.then, label %for.body.preheader, !dbg !61

if.then:                                          ; preds = %entry
  %puts12 = call i32 @puts(ptr nonnull @str.4), !dbg !62
  call void @llvm.dbg.value(metadata ptr %n, metadata !51, metadata !DIExpression(DW_OP_deref)), !dbg !56
  %call2 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %n), !dbg !64
  br label %cleanup, !dbg !65

for.body.preheader:                               ; preds = %entry
  %conv = zext i32 %0 to i64
  %call3 = call noalias ptr @malloc(i64 noundef %conv) #9, !dbg !66
  call void @llvm.dbg.value(metadata ptr %call3, metadata !52, metadata !DIExpression()), !dbg !56
  call void @llvm.dbg.value(metadata i32 0, metadata !53, metadata !DIExpression()), !dbg !67
  call void @llvm.dbg.value(metadata i32 %0, metadata !51, metadata !DIExpression()), !dbg !56
  br label %for.body, !dbg !68

for.cond.cleanup:                                 ; preds = %for.body
  call void @free(ptr noundef %call3) #8, !dbg !69
  call void @free(ptr noundef %call3) #8, !dbg !70
  %puts = call i32 @puts(ptr nonnull @str), !dbg !71
  br label %cleanup

for.body:                                         ; preds = %for.body.preheader, %for.body
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !53, metadata !DIExpression()), !dbg !67
  %arrayidx = getelementptr inbounds i32, ptr %call3, i64 %indvars.iv, !dbg !72
  %call6 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %arrayidx), !dbg !74
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !75
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next, metadata !53, metadata !DIExpression()), !dbg !67
  %1 = load i32, ptr %n, align 4, !dbg !76, !tbaa !42
  call void @llvm.dbg.value(metadata i32 %1, metadata !51, metadata !DIExpression()), !dbg !56
  %2 = sext i32 %1 to i64, !dbg !77
  %cmp4 = icmp slt i64 %indvars.iv.next, %2, !dbg !77
  br i1 %cmp4, label %for.body, label %for.cond.cleanup, !dbg !68, !llvm.loop !78

cleanup:                                          ; preds = %for.cond.cleanup, %if.then
  %retval.0 = phi i32 [ -2, %if.then ], [ -1, %for.cond.cleanup ], !dbg !56
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %n) #8, !dbg !81
  ret i32 %retval.0, !dbg !81
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(ptr nocapture noundef readonly, ...) local_unnamed_addr #3

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #3

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #4

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free")
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #5

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #1 !dbg !82 {
entry:
  %call = tail call i32 @usep(), !dbg !85, !range !86
  %call1 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.3, i32 noundef %call), !dbg !87
  tail call void @test(ptr noundef undef), !dbg !88
  ret i32 0, !dbg !89
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #6

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #7

attributes #0 = { argmemonly mustprogress nofree noinline norecurse nosync nounwind willreturn writeonly uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { argmemonly mustprogress nocallback nofree nosync nounwind willreturn }
attributes #3 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free") "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { nofree nounwind }
attributes #8 = { nounwind }
attributes #9 = { nounwind allocsize(0) }

!llvm.dbg.cu = !{!12}
!llvm.module.flags = !{!27, !28, !29, !30, !31, !32}
!llvm.ident = !{!33}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 10, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "demo1.c", directory: "/home/secondst/code/MyAnalysis/demo", checksumkind: CSK_MD5, checksum: "af96f42bf0a189d086b74c49254c7524")
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
!18 = distinct !DIGlobalVariable(scope: null, file: !2, line: 12, type: !19, isLocal: true, isDefinition: true)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 248, elements: !20)
!20 = !{!21}
!21 = !DISubrange(count: 31)
!22 = !DIGlobalVariableExpression(var: !23, expr: !DIExpression())
!23 = distinct !DIGlobalVariable(scope: null, file: !2, line: 21, type: !24, isLocal: true, isDefinition: true)
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
!36 = !{null, !14}
!37 = !{!38}
!38 = !DILocalVariable(name: "p1", arg: 1, scope: !34, file: !2, line: 4, type: !14)
!39 = !DILocation(line: 0, scope: !34)
!40 = !DILocation(line: 5, column: 5, scope: !34)
!41 = !DILocation(line: 5, column: 13, scope: !34)
!42 = !{!43, !43, i64 0}
!43 = !{!"int", !44, i64 0}
!44 = !{!"omnipotent char", !45, i64 0}
!45 = !{!"Simple C/C++ TBAA"}
!46 = !DILocation(line: 6, column: 1, scope: !34)
!47 = distinct !DISubprogram(name: "usep", scope: !2, file: !2, line: 8, type: !48, scopeLine: 8, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !50)
!48 = !DISubroutineType(types: !49)
!49 = !{!15}
!50 = !{!51, !52, !53}
!51 = !DILocalVariable(name: "n", scope: !47, file: !2, line: 9, type: !15)
!52 = !DILocalVariable(name: "p1", scope: !47, file: !2, line: 16, type: !14)
!53 = !DILocalVariable(name: "i", scope: !54, file: !2, line: 17, type: !15)
!54 = distinct !DILexicalBlock(scope: !47, file: !2, line: 17, column: 5)
!55 = !DILocation(line: 9, column: 5, scope: !47)
!56 = !DILocation(line: 0, scope: !47)
!57 = !DILocation(line: 10, column: 5, scope: !47)
!58 = !DILocation(line: 11, column: 8, scope: !59)
!59 = distinct !DILexicalBlock(scope: !47, file: !2, line: 11, column: 8)
!60 = !DILocation(line: 11, column: 9, scope: !59)
!61 = !DILocation(line: 11, column: 8, scope: !47)
!62 = !DILocation(line: 12, column: 9, scope: !63)
!63 = distinct !DILexicalBlock(scope: !59, file: !2, line: 11, column: 13)
!64 = !DILocation(line: 13, column: 9, scope: !63)
!65 = !DILocation(line: 14, column: 9, scope: !63)
!66 = !DILocation(line: 16, column: 21, scope: !47)
!67 = !DILocation(line: 0, scope: !54)
!68 = !DILocation(line: 17, column: 5, scope: !54)
!69 = !DILocation(line: 19, column: 5, scope: !47)
!70 = !DILocation(line: 20, column: 5, scope: !47)
!71 = !DILocation(line: 21, column: 5, scope: !47)
!72 = !DILocation(line: 18, column: 21, scope: !73)
!73 = distinct !DILexicalBlock(scope: !54, file: !2, line: 17, column: 5)
!74 = !DILocation(line: 18, column: 9, scope: !73)
!75 = !DILocation(line: 17, column: 22, scope: !73)
!76 = !DILocation(line: 17, column: 19, scope: !73)
!77 = !DILocation(line: 17, column: 18, scope: !73)
!78 = distinct !{!78, !68, !79, !80}
!79 = !DILocation(line: 18, column: 26, scope: !54)
!80 = !{!"llvm.loop.mustprogress"}
!81 = !DILocation(line: 23, column: 1, scope: !47)
!82 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 25, type: !48, scopeLine: 25, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !83)
!83 = !{!84}
!84 = !DILocalVariable(name: "p", scope: !82, file: !2, line: 27, type: !14)
!85 = !DILocation(line: 26, column: 19, scope: !82)
!86 = !{i32 -2, i32 0}
!87 = !DILocation(line: 26, column: 5, scope: !82)
!88 = !DILocation(line: 28, column: 5, scope: !82)
!89 = !DILocation(line: 30, column: 5, scope: !82)
