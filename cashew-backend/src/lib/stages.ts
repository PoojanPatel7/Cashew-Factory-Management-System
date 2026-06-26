/** Processing stage order — matches Flutter kanban & constants */
export const PROCESSING_STAGES = [
  'CLEANING',
  'STEAMING',
  'COOLING',
  'SHELLING',
  'DRYING',
  'PEELING',
  'GRADING',
  'PACKING',
] as const;

export type ProcessingStage = (typeof PROCESSING_STAGES)[number];

const STAGE_LABELS: Record<ProcessingStage, string> = {
  CLEANING: 'Cleaning',
  STEAMING: 'Boiling',
  COOLING: 'Cooling',
  SHELLING: 'Shelling',
  DRYING: 'Borma',
  PEELING: 'Peeling',
  GRADING: 'Grading',
  PACKING: 'Packing',
};

export function stageToLabel(stage: string): string {
  return STAGE_LABELS[stage as ProcessingStage] ?? stage;
}

export function labelToStage(label: string): string {
  const entry = Object.entries(STAGE_LABELS).find(([, v]) => v === label);
  return entry?.[0] ?? label.toUpperCase();
}

export function nextStage(current: string): string | null {
  const idx = PROCESSING_STAGES.indexOf(current as ProcessingStage);
  if (idx < 0 || idx >= PROCESSING_STAGES.length - 1) return null;
  return PROCESSING_STAGES[idx + 1];
}

export function formatLotForUi(lot: {
  id: string;
  lotNumber: string;
  initialWeight: number;
  currentStage: string;
  status: string;
  startDate: Date;
  stageLogs?: unknown[];
}) {
  return {
    id: lot.id,
    lotNumber: lot.lotNumber,
    qty: lot.initialWeight,
    qtyLabel: `${lot.initialWeight} kg`,
    stage: stageToLabel(lot.currentStage),
    stageCode: lot.currentStage,
    status: lot.status === 'IN_PROGRESS' ? 'Active' : lot.status,
    startDate: lot.startDate.toISOString(),
    stageLogs: lot.stageLogs ?? [],
  };
}
