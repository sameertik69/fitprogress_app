const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type AnalysisPayload = {
  photos?: Array<{ angle: string; sizeBytes?: number }>;
  previousSessions?: Array<Record<string, unknown>>;
  context?: {
    weightKg?: number | null;
    phaseLabel?: string;
    note?: string;
    measurements?: {
      waistCm?: number | null;
      chestCm?: number | null;
      armCm?: number | null;
      shoulderCm?: number | null;
    };
  };
  readiness?: {
    level?: string;
    message?: string;
  } | null;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const payload = (await req.json()) as AnalysisPayload;
    const result = createMockAiResult(payload);

    return json({ result });
  } catch (_error) {
    return json({ error: "Invalid analysis request" }, 400);
  }
});

function createMockAiResult(payload: AnalysisPayload) {
  const sessionNumber = (payload.previousSessions?.length ?? 0) + 1;
  const photoCount = payload.photos?.length ?? 0;
  const visualScore = clamp(72 + sessionNumber * 3, 0, 96);
  const postureScore = clamp(78 + photoCount * 3 + sessionNumber, 0, 96);
  const attention =
    payload.readiness?.level === "attention"
      ? " توجد ملاحظة على جاهزية الصور لذلك تم تخفيض الثقة قليلًا."
      : "";
  const note =
    payload.context?.note && payload.context.note.trim().length > 0
      ? " ملاحظتك أضيفت كسياق للتحليل."
      : "";
  const muscleMetrics = [
    muscleMetric("الأكتاف", visualScore + 4, "قراءة اتساع الجزء العلوي مقارنة بالخصر."),
    muscleMetric("الصدر", visualScore + sessionNumber, "تقدير امتلاء الصدر من الصورة الأمامية."),
    muscleMetric("الذراعين", visualScore - 2 + sessionNumber, "قراءة تقديرية تتأثر بزاوية الذراعين."),
    muscleMetric("الخصر والجذع", Math.round((visualScore + postureScore) / 2), "يعتمد على ثبات الوقفة ونسبة الكتف إلى الخصر."),
  ];

  return {
    visualScore,
    confidence: postureScore >= 88 ? "مرتفع" : "متوسط",
    postureScore,
    summary:
      `تحليل AI تجريبي للجلسة رقم ${sessionNumber}: الصور مكتملة بعدد ${photoCount} زوايا، والنتيجة تشير إلى قابلية مقارنة جيدة.${attention}${note}`,
    symmetryLabel: visualScore >= 84 ? "ممتاز" : "جيد",
    comparabilityLabel: postureScore >= 86 ? "قوية" : "مقبولة",
    shoulderWaistChange: Number((3.8 + sessionNumber * 0.8).toFixed(1)),
    recommendation:
      "حافظ على نفس الإضاءة والمسافة والوقفة في الجلسة القادمة لتحسين دقة المقارنة.",
    muscleMetrics,
  };
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}

function muscleMetric(name: string, score: number, note: string) {
  const normalizedScore = clamp(score, 0, 100);
  return {
    name,
    score: normalizedScore,
    status: statusFor(normalizedScore),
    note,
  };
}

function statusFor(score: number) {
  if (score >= 85) return "قوي";
  if (score >= 76) return "جيد";
  if (score >= 68) return "مقبول";
  return "بحاجة لمتابعة";
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
