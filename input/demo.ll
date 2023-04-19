; ModuleID = 'demo.c'
source_filename = "demo.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0
@.str.3 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1, !dbg !7
@str = private unnamed_addr constant [13 x i8] c"double free!\00", align 1
@str.4 = private unnamed_addr constant [30 x i8] c"too small, try one more time!\00", align 1

; Function Attrs: mustprogress noinline nounwind willreturn uwtable
define dso_local void @test(ptr nocapture noundef %p1, i32 %x) local_unnamed_addr #0 !dbg !34 {
entry:
  call void @llvm.dbg.value(metadata ptr %p1, metadata !38, metadata !DIExpression()), !dbg !40
  call void @llvm.dbg.value(metadata i32 poison, metadata !39, metadata !DIExpression()), !dbg !40
  tail call void @free(ptr noundef %p1) #8, !dbg !41
  ret void, !dbg !42
}

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn allockind("free")
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #1

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @usep() local_unnamed_addr #2 !dbg !43 {
entry:
  %vvv = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %vvv) #8, !dbg !51
  call void @llvm.dbg.value(metadata ptr %vvv, metadata !47, metadata !DIExpression(DW_OP_deref)), !dbg !52
  %call = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %vvv), !dbg !53
  %0 = load i32, ptr %vvv, align 4, !dbg !54, !tbaa !56
  call void @llvm.dbg.value(metadata i32 %0, metadata !47, metadata !DIExpression()), !dbg !52
  %cmp = icmp slt i32 %0, 10, !dbg !60
  br i1 %cmp, label %if.then, label %for.body.preheader, !dbg !61

if.then:                                          ; preds = %entry
  %puts11 = call i32 @puts(ptr nonnull @str.4), !dbg !62
  call void @llvm.dbg.value(metadata ptr %vvv, metadata !47, metadata !DIExpression(DW_OP_deref)), !dbg !52
  %call2 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef nonnull %vvv), !dbg !64
  br label %cleanup, !dbg !65

for.body.preheader:                               ; preds = %entry
  call void @llvm.dbg.value(metadata ptr null, metadata !48, metadata !DIExpression()), !dbg !52
  %conv = zext i32 %0 to i64
  %call3 = call noalias ptr @calloc(i64 noundef %conv, i64 noundef 4) #9, !dbg !66
  call void @llvm.dbg.value(metadata ptr %call3, metadata !48, metadata !DIExpression()), !dbg !52
  call void @llvm.dbg.value(metadata i32 0, metadata !49, metadata !DIExpression()), !dbg !67
  call void @llvm.dbg.value(metadata i32 %0, metadata !47, metadata !DIExpression()), !dbg !52
  br label %for.body, !dbg !68

for.cond.cleanup:                                 ; preds = %for.body
  call void @free(ptr noundef %call3) #8, !dbg !69
  %puts = call i32 @puts(ptr nonnull @str), !dbg !70
  br label %cleanup

for.body:                                         ; preds = %for.body.preheader, %for.body
  %indvars.iv = phi i64 [ 0, %for.body.preheader ], [ %indvars.iv.next, %for.body ]
  call void @llvm.dbg.value(metadata i64 %indvars.iv, metadata !49, metadata !DIExpression()), !dbg !67
  %arrayidx = getelementptr inbounds i32, ptr %call3, i64 %indvars.iv, !dbg !71
  %call6 = call i32 (ptr, ...) @__isoc99_scanf(ptr noundef nonnull @.str, ptr noundef %arrayidx), !dbg !73
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !74
  call void @llvm.dbg.value(metadata i64 %indvars.iv.next, metadata !49, metadata !DIExpression()), !dbg !67
  %1 = load i32, ptr %vvv, align 4, !dbg !75, !tbaa !56
  call void @llvm.dbg.value(metadata i32 %1, metadata !47, metadata !DIExpression()), !dbg !52
  %2 = sext i32 %1 to i64, !dbg !76
  %cmp4 = icmp slt i64 %indvars.iv.next, %2, !dbg !76
  br i1 %cmp4, label %for.body, label %for.cond.cleanup, !dbg !68, !llvm.loop !77

cleanup:                                          ; preds = %for.cond.cleanup, %if.then
  %retval.0 = phi i32 [ -2, %if.then ], [ -1, %for.cond.cleanup ], !dbg !52
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %vvv) #8, !dbg !80
  ret i32 %retval.0, !dbg !80
}

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #3

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(ptr nocapture noundef readonly, ...) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #4

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1)
declare noalias noundef ptr @calloc(i64 noundef, i64 noundef) local_unnamed_addr #5

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #3

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #2 !dbg !81 {
entry:
  %call = tail call i32 @usep(), !dbg !84, !range !85
  %call1 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull @.str.3, i32 noundef %call), !dbg !86
  tail call void @test(ptr noundef undef, i32 poison), !dbg !87
  ret i32 0, !dbg !88
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
attributes #5 = { inaccessiblememonly mustprogress nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) "alloc-family"="malloc" "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #7 = { nofree nounwind }
attributes #8 = { nounwind }
attributes #9 = { nounwind allocsize(0,1) }

!llvm.dbg.cu = !{!12}
!llvm.module.flags = !{!27, !28, !29, !30, !31, !32}
!llvm.ident = !{!33}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 11, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "demo.c", directory: "/home/secondst/code/MyAnalysis/demo", checksumkind: CSK_MD5, checksum: "69129bb4c9134888bb283f235f393186")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = !DIGlobalVariableExpression(var: !8, expr: !DIExpression())
!8 = distinct !DIGlobalVariable(scope: null, file: !2, line: 27, type: !9, isLocal: true, isDefinition: true)
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
!23 = distinct !DIGlobalVariable(scope: null, file: !2, line: 22, type: !24, isLocal: true, isDefinition: true)
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
!37 = !{!38, !39}
!38 = !DILocalVariable(name: "p1", arg: 1, scope: !34, file: !2, line: 4, type: !14)
!39 = !DILocalVariable(name: "x", arg: 2, scope: !34, file: !2, line: 4, type: !15)
!40 = !DILocation(line: 0, scope: !34)
!41 = !DILocation(line: 5, column: 5, scope: !34)
!42 = !DILocation(line: 6, column: 1, scope: !34)
!43 = distinct !DISubprogram(name: "usep", scope: !2, file: !2, line: 8, type: !44, scopeLine: 8, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !46)
!44 = !DISubroutineType(types: !45)
!45 = !{!15}
!46 = !{!47, !48, !49}
!47 = !DILocalVariable(name: "vvv", scope: !43, file: !2, line: 10, type: !15)
!48 = !DILocalVariable(name: "p1", scope: !43, file: !2, line: 17, type: !14)
!49 = !DILocalVariable(name: "i", scope: !50, file: !2, line: 19, type: !15)
!50 = distinct !DILexicalBlock(scope: !43, file: !2, line: 19, column: 3)
!51 = !DILocation(line: 10, column: 3, scope: !43)
!52 = !DILocation(line: 0, scope: !43)
!53 = !DILocation(line: 11, column: 3, scope: !43)
!54 = !DILocation(line: 12, column: 7, scope: !55)
!55 = distinct !DILexicalBlock(scope: !43, file: !2, line: 12, column: 7)
!56 = !{!57, !57, i64 0}
!57 = !{!"int", !58, i64 0}
!58 = !{!"omnipotent char", !59, i64 0}
!59 = !{!"Simple C/C++ TBAA"}
!60 = !DILocation(line: 12, column: 11, scope: !55)
!61 = !DILocation(line: 12, column: 7, scope: !43)
!62 = !DILocation(line: 13, column: 5, scope: !63)
!63 = distinct !DILexicalBlock(scope: !55, file: !2, line: 12, column: 17)
!64 = !DILocation(line: 14, column: 5, scope: !63)
!65 = !DILocation(line: 15, column: 5, scope: !63)
!66 = !DILocation(line: 18, column: 15, scope: !43)
!67 = !DILocation(line: 0, scope: !50)
!68 = !DILocation(line: 19, column: 3, scope: !50)
!69 = !DILocation(line: 21, column: 3, scope: !43)
!70 = !DILocation(line: 22, column: 3, scope: !43)
!71 = !DILocation(line: 20, column: 18, scope: !72)
!72 = distinct !DILexicalBlock(scope: !50, file: !2, line: 19, column: 3)
!73 = !DILocation(line: 20, column: 5, scope: !72)
!74 = !DILocation(line: 19, column: 29, scope: !72)
!75 = !DILocation(line: 19, column: 23, scope: !72)
!76 = !DILocation(line: 19, column: 21, scope: !72)
!77 = distinct !{!77, !68, !78, !79}
!78 = !DILocation(line: 20, column: 23, scope: !50)
!79 = !{!"llvm.loop.mustprogress"}
!80 = !DILocation(line: 24, column: 1, scope: !43)
!81 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 26, type: !44, scopeLine: 26, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !12, retainedNodes: !82)
!82 = !{!83}
!83 = !DILocalVariable(name: "p", scope: !81, file: !2, line: 28, type: !14)
!84 = !DILocation(line: 27, column: 18, scope: !81)
!85 = !{i32 -2, i32 0}
!86 = !DILocation(line: 27, column: 3, scope: !81)
!87 = !DILocation(line: 29, column: 3, scope: !81)
!88 = !DILocation(line: 30, column: 3, scope: !81)
