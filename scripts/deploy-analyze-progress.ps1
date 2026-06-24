param(
  [string]$ProjectRef = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
  throw "Supabase CLI is not installed or not available in PATH."
}

if ([string]::IsNullOrWhiteSpace($ProjectRef)) {
  supabase functions deploy analyze-progress
} else {
  supabase functions deploy analyze-progress --project-ref $ProjectRef
}
