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
  };
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
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
