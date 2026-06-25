import { Router } from 'express';
import { createLot, getLots, completeStage } from '../controllers/processingController';

const router = Router();

router.post('/lots', createLot);
router.get('/lots', getLots);
router.post('/lots/:id/stages', completeStage);

export default router;
