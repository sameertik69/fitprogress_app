const aiAnalysisFunctionName = String.fromEnvironment(
  'AI_ANALYSIS_FUNCTION',
  defaultValue: 'analyze-progress',
);

bool get hasAiAnalysisFunctionName => aiAnalysisFunctionName.isNotEmpty;
