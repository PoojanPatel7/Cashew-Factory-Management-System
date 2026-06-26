import { Router } from 'express';
import {
  getRawStock, addRawStock, deleteRawStock, getRawStockDetail,
  getSortings, createSorting,
  getLots, getLotDetail, startLot, completeStage,
  getFinishedStock, dispatchStock,
  getDashboard, getWastage,
  deleteProcessingStep, editLot,
  revertToStage, addStepRecord,
  unstartLot, revertSorting,
  getGlobalDashboard, transferLot,
  transferRawStock, transferFinishedStock,
  mergeRawStock, editRawStock
} from '../controllers/stockController';

const router = Router();

// Dashboard
router.get('/dashboard', getDashboard);
router.get('/global-dashboard', getGlobalDashboard);

// Wastage
router.get('/wastage', getWastage);

// Raw Stock
router.get('/raw', getRawStock);
router.post('/raw', addRawStock);
router.get('/raw/:id', getRawStockDetail);
router.put('/raw/:id', editRawStock);
router.delete('/raw/:id', deleteRawStock);
router.post('/raw-stock/merge', mergeRawStock);
router.post('/raw-stock/:id/transfer', transferRawStock);

// Sorting
router.get('/sorting', getSortings);
router.post('/sorting', createSorting);
router.delete('/sorting/:id', revertSorting);

// Lots & Processing
router.get('/lots', getLots);
router.get('/lots/:id', getLotDetail);
router.post('/lots/:id/transfer', transferLot);
router.patch('/lots/:id/start', startLot);
router.post('/lots/:id/unstart', unstartLot);
router.post('/lots/:id/complete-stage', completeStage);
router.put('/lots/:id', editLot);
router.post('/lots/:id/revert-to-stage', revertToStage);
router.post('/lots/:id/add-step', addStepRecord);
router.delete('/processing-step/:id', deleteProcessingStep);

// Finished Stock & Dispatch
router.get('/finished', getFinishedStock);
router.post('/finished/:id/dispatch', dispatchStock);
router.post('/finished-stock/:id/transfer', transferFinishedStock);

export default router;
