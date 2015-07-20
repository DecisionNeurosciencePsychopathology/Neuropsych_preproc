function h = MostFrequentKHasing(string_in,K)

% count occurence of each unique character
uniq_chars_in = unique(string_in);
uniq_counts = zeros(size(uniq_str_in));

parfor nchar = 1:length(uniq_chars_in)
    uniq_counts(nchar) = sum( uniq_str_in(nchar) == string_in );
end





String function MostFreqKHashing (String inputString, int K)
    def string outputString
    for each distinct character
        count occurrence of each character
    for i := 0 to K
        char c = next most freq ith character  (if two chars have same frequency than get the first
occurrence in inputString)
        int count = number of occurrence of the character
        append to outputString, c and count
    end for
    return outputString



int function MostFreqKSimilarity (String inputStr1, String inputStr2)
    def int similarity
    for each c = next character from inputStr1
        lookup c in inputStr2
        if c is null
             continue
        similarity += frequency of c in inputStr1 + frequency of c in inputStr2
    return similarity



int function MostFreqKSDF (String inputStr1, String inputStr2, int K, int maxDistance)
    return maxDistance - MostFreqKSimilarity(MostFreqKHashing(inputStr1, K),
MostFreqKHashing(inputStr2, K))
