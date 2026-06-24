import '../models/analysis_request.dart';

const _analysisModeName = String.fromEnvironment(
  'ANALYSIS_MODE',
  defaultValue: 'mock',
);

const analysisMode = _analysisModeName == 'ai'
    ? AnalysisMode.ai
    : AnalysisMode.mock;
