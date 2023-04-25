#include <iostream>
#include <vector>
#include <algorithm>

double getSequenceMatcherRatio(std::string seq1, std::string seq2) {
    int len1 = seq1.length(), len2 = seq2.length();
    std::vector<std::vector<int>> dp(len1 + 1, std::vector<int>(len2 + 1, 0));
    for (int i = 1; i <= len1; ++i) {
        for (int j = 1; j <= len2; ++j) {
            if (seq1[i - 1] == seq2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
            } else {
                dp[i][j] = std::max(dp[i - 1][j], dp[i][j - 1]);
            }
        }
    }
    int lcs = dp[len1][len2];
    return 2.0 * lcs / (len1 + len2);
}

int main() {
    std::string seq1 = "%16 = phi ptr [ %7, %5 ], [ %13, %8 ]   br label %20";
    std::string seq2 = "%22 = phi i32 [ -2, %5 ], [ -1, %11 ]   call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %1) #6   ret i32 %22";
    double ratio = getSequenceMatcherRatio(seq1, seq2);
    std::cout << ratio << std::endl;
    return 0;
}
