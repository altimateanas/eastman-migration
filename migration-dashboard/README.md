# MS SQL Server to Fabric Migration Dashboard

An interactive dashboard visualizing the data migration from **MS SQL Server** to **Microsoft Fabric**, including Medallion Architecture lineage, data parity validation (via `data_diff`), and row-level comparison results.

## Quick Start

### Prerequisites

- **Node.js** >= 18 (check with `node -v`)
- **npm** >= 9 (check with `npm -v`)

### Launch the Dashboard

```bash
# 1. Navigate to the dashboard directory
cd migration-dashboard

# 2. Install dependencies
npm install

# 3. Start the development server
npm run dev
```

The dashboard will be available at **http://localhost:5173/** (or the next available port — check the terminal output).

### Build for Production

```bash
# Build a static bundle
npm run build

# Preview the production build locally
npm run preview
```

The built files will be in `dist/` — you can deploy this to any static hosting (GitHub Pages, Vercel, Netlify, Azure Static Web Apps, etc.).

## What's in the Dashboard

| Section                    | Description                                                               |
| -------------------------- | ------------------------------------------------------------------------- |
| **KPI Cards**              | Tables validated, rows checked, data parity %, total dbt models           |
| **Migration Overview**     | Visual flow: MS SQL Server → dbt + data_diff → Microsoft Fabric           |
| **Medallion Architecture** | Bronze (10 RAW) → Silver (10 staging) → Gold (6 dims + 2 facts)           |
| **Data Lineage DAG**       | Interactive D3 graph of all 28 models across 3 layers (drag, zoom, pan)   |
| **Data Diff Results**      | Expandable table showing row-level validation for all 8 gold-layer tables |
| **Row Count Comparison**   | Side-by-side bar chart: MS SQL (red) vs Fabric (blue)                     |
| **Table Size Treemap**     | Proportional visualization by row count, color-coded by type              |

## Tech Stack

- [Vite](https://vite.dev/) — Fast build tool
- [React](https://react.dev/) + TypeScript — UI framework
- [Tailwind CSS](https://tailwindcss.com/) — Utility-first styling
- [Recharts](https://recharts.org/) — Bar charts, pie/donut, treemap
- [D3.js](https://d3js.org/) — Interactive lineage DAG with zoom/pan
- [Lucide React](https://lucide.dev/) — Icons

## Project Structure

```
migration-dashboard/
├── src/
│   ├── App.tsx                      # Main dashboard layout
│   ├── index.css                    # Tailwind + theme variables
│   ├── components/
│   │   └── LineageDAG.tsx           # D3 force-directed lineage graph
│   └── data/
│       └── migration-data.ts        # All migration data (tables, lineage, diff results)
├── package.json
├── vite.config.ts
├── tsconfig.json
└── README.md
```

## Updating the Data

All dashboard data lives in `src/data/migration-data.ts`. To update after re-running migrations or data diffs:

1. Update `bronzeTables`, `goldTables` arrays with new row counts or diff statuses
2. Update `lineageNodes` / `lineageEdges` if models change
3. Update `migrationSummary` with new totals
4. The dashboard will hot-reload automatically in dev mode
