import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const lots = await prisma.lot.findMany({
    include: {
      sorting: {
        include: {
          rawStock: { select: { name: true } },
          rawStocks: { include: { rawStock: { select: { name: true } } } }
        }
      }
    }
  });
  console.dir(lots, { depth: null });
}

main().catch(console.error).finally(() => prisma.$disconnect());
