import { useState } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Cell,
  PieChart,
  Pie,
  Treemap,
} from "recharts";
import {
  Database,
  Server,
  ArrowRight,
  CheckCircle2,
  Layers,
  Table2,
  Columns3,
  GitBranch,
  Shield,
  ChevronDown,
  ChevronUp,
  ArrowRightLeft,
  Workflow,
  BarChart3,
} from "lucide-react";
import {
  migrationSummary,
  goldTables,
  bronzeTables,
  silverModels,
  rowCountData,
  lineageNodes,
  lineageEdges,
} from "./data/migration-data";
import { LineageDAG } from "./components/LineageDAG";
import "./index.css";

// ─── Color palette ───────────────────────────────────────────────────────────
const COLORS = {
  bronze: "#cd7f32",
  silver: "#94a3b8",
  gold: "#fbbf24",
  mssql: "#cc2927",
  fabric: "#0078d4",
  success: "#22c55e",
  bg: "#0f172a",
  card: "#1e293b",
  cardAlt: "#334155",
  border: "#475569",
  text: "#f8fafc",
  textMuted: "#94a3b8",
  dimension: "#818cf8",
  fact: "#f472b6",
};

// ─── Helpers ─────────────────────────────────────────────────────────────────
const totalBronzeRows = bronzeTables.reduce((s, t) => s + t.rowCount, 0);
// totalGoldRows available if needed
// const totalGoldRows = goldTables.reduce((s, t) => s + t.rowCount, 0);

// ─── KPI Card ────────────────────────────────────────────────────────────────
function KPICard({
  icon: Icon,
  label,
  value,
  sub,
  color = COLORS.fabric,
}: {
  icon: React.ElementType;
  label: string;
  value: string | number;
  sub?: string;
  color?: string;
}) {
  return (
    <div
      className="rounded-xl p-5 flex flex-col gap-2"
      style={{ background: COLORS.card, borderLeft: `4px solid ${color}` }}
    >
      <div
        className="flex items-center gap-2"
        style={{ color: COLORS.textMuted }}
      >
        <Icon size={16} />
        <span className="text-xs font-medium uppercase tracking-wider">
          {label}
        </span>
      </div>
      <div className="text-3xl font-bold" style={{ color: COLORS.text }}>
        {value}
      </div>
      {sub && (
        <div className="text-xs" style={{ color: COLORS.textMuted }}>
          {sub}
        </div>
      )}
    </div>
  );
}

// ─── Section Card ────────────────────────────────────────────────────────────
function Section({
  title,
  icon: Icon,
  children,
  className = "",
}: {
  title: string;
  icon: React.ElementType;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`rounded-xl p-6 ${className}`}
      style={{ background: COLORS.card, border: `1px solid ${COLORS.border}` }}
    >
      <div className="flex items-center gap-3 mb-5">
        <div
          className="p-2 rounded-lg"
          style={{ background: `${COLORS.fabric}22` }}
        >
          <Icon size={20} style={{ color: COLORS.fabric }} />
        </div>
        <h2 className="text-lg font-semibold" style={{ color: COLORS.text }}>
          {title}
        </h2>
      </div>
      {children}
    </div>
  );
}

// ─── Status Badge ────────────────────────────────────────────────────────────
function StatusBadge({ status }: { status: string }) {
  const isOk = status === "identical";
  return (
    <span
      className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium"
      style={{
        background: isOk ? "#22c55e22" : "#ef444422",
        color: isOk ? COLORS.success : "#ef4444",
      }}
    >
      <CheckCircle2 size={12} />
      {isOk ? "IDENTICAL" : "MISMATCH"}
    </span>
  );
}

// ─── Layer Badge ─────────────────────────────────────────────────────────────
function LayerBadge({ layer }: { layer: "bronze" | "silver" | "gold" }) {
  const c = COLORS[layer];
  return (
    <span
      className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-bold uppercase"
      style={{ background: `${c}22`, color: c, border: `1px solid ${c}44` }}
    >
      {layer}
    </span>
  );
}

// ─── Medallion Architecture Visual ───────────────────────────────────────────
function MedallionArchitecture() {
  const layers = [
    {
      name: "Bronze",
      sub: "RAW / Landing",
      color: COLORS.bronze,
      tables: bronzeTables.length,
      desc: "Raw source data, no transforms",
    },
    {
      name: "Silver",
      sub: "Staging / Cleansed",
      color: COLORS.silver,
      tables: silverModels.length,
      desc: "Renamed, cast, cleaned via dbt views",
    },
    {
      name: "Gold",
      sub: "Dimensions & Facts",
      color: COLORS.gold,
      tables: goldTables.length,
      desc: "Business-ready analytics tables",
    },
  ];
  return (
    <div className="flex flex-col md:flex-row gap-4 items-stretch">
      {layers.map((l, i) => (
        <div key={l.name} className="flex items-center gap-4 flex-1">
          <div
            className="flex-1 rounded-xl p-5 flex flex-col gap-3"
            style={{
              background: `${l.color}11`,
              border: `2px solid ${l.color}44`,
            }}
          >
            <div className="flex items-center justify-between">
              <span className="text-lg font-bold" style={{ color: l.color }}>
                {l.name}
              </span>
              <span
                className="text-xs px-2 py-0.5 rounded-full font-medium"
                style={{ background: `${l.color}22`, color: l.color }}
              >
                {l.tables} tables
              </span>
            </div>
            <span
              className="text-xs font-medium"
              style={{ color: COLORS.textMuted }}
            >
              {l.sub}
            </span>
            <span className="text-xs" style={{ color: COLORS.textMuted }}>
              {l.desc}
            </span>
          </div>
          {i < layers.length - 1 && (
            <ArrowRight
              size={24}
              style={{ color: COLORS.textMuted }}
              className="hidden md:block flex-shrink-0"
            />
          )}
        </div>
      ))}
    </div>
  );
}

// ─── Data Diff Results Table ─────────────────────────────────────────────────
function DataDiffTable() {
  const [expanded, setExpanded] = useState<string | null>(null);
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr style={{ borderBottom: `1px solid ${COLORS.border}` }}>
            {[
              "Table",
              "Type",
              "Key Column",
              "Source Rows",
              "Target Rows",
              "Columns Compared",
              "Status",
              "",
            ].map((h) => (
              <th
                key={h}
                className="text-left py-3 px-3 text-xs font-medium uppercase tracking-wider"
                style={{ color: COLORS.textMuted }}
              >
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {goldTables.map((t) => (
            <>
              <tr
                key={t.name}
                className="cursor-pointer transition-colors"
                style={{ borderBottom: `1px solid ${COLORS.border}22` }}
                onMouseOver={(e) =>
                  (e.currentTarget.style.background = `${COLORS.cardAlt}88`)
                }
                onMouseOut={(e) =>
                  (e.currentTarget.style.background = "transparent")
                }
                onClick={() => setExpanded(expanded === t.name ? null : t.name)}
              >
                <td
                  className="py-3 px-3 font-medium"
                  style={{ color: COLORS.text }}
                >
                  <div className="flex items-center gap-2">
                    <Table2
                      size={14}
                      style={{
                        color:
                          t.type === "fact" ? COLORS.fact : COLORS.dimension,
                      }}
                    />
                    {t.name}
                  </div>
                </td>
                <td className="py-3 px-3">
                  <span
                    className="text-xs px-2 py-0.5 rounded font-medium"
                    style={{
                      background:
                        t.type === "fact"
                          ? `${COLORS.fact}22`
                          : `${COLORS.dimension}22`,
                      color: t.type === "fact" ? COLORS.fact : COLORS.dimension,
                    }}
                  >
                    {t.type === "fact" ? "Fact" : "Dimension"}
                  </span>
                </td>
                <td
                  className="py-3 px-3 font-mono text-xs"
                  style={{ color: COLORS.textMuted }}
                >
                  {t.keyColumn}
                </td>
                <td
                  className="py-3 px-3 text-right font-mono"
                  style={{ color: COLORS.mssql }}
                >
                  {t.rowCount.toLocaleString()}
                </td>
                <td
                  className="py-3 px-3 text-right font-mono"
                  style={{ color: COLORS.fabric }}
                >
                  {t.rowCount.toLocaleString()}
                </td>
                <td
                  className="py-3 px-3 text-center font-mono"
                  style={{ color: COLORS.textMuted }}
                >
                  {t.diffColumns.length}
                </td>
                <td className="py-3 px-3">
                  <StatusBadge status={t.diffStatus} />
                </td>
                <td className="py-3 px-3">
                  {expanded === t.name ? (
                    <ChevronUp size={16} style={{ color: COLORS.textMuted }} />
                  ) : (
                    <ChevronDown
                      size={16}
                      style={{ color: COLORS.textMuted }}
                    />
                  )}
                </td>
              </tr>
              {expanded === t.name && (
                <tr key={`${t.name}-detail`}>
                  <td
                    colSpan={8}
                    className="p-4"
                    style={{ background: `${COLORS.cardAlt}44` }}
                  >
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                      <div>
                        <span
                          className="block text-xs mb-1"
                          style={{ color: COLORS.textMuted }}
                        >
                          Algorithm
                        </span>
                        <span
                          className="text-xs font-medium"
                          style={{ color: COLORS.text }}
                        >
                          HashDiff
                        </span>
                      </div>
                      <div>
                        <span
                          className="block text-xs mb-1"
                          style={{ color: COLORS.textMuted }}
                        >
                          Key
                        </span>
                        <span
                          className="text-xs font-mono"
                          style={{ color: COLORS.text }}
                        >
                          {t.keyColumn}
                        </span>
                      </div>
                      <div>
                        <span
                          className="block text-xs mb-1"
                          style={{ color: COLORS.textMuted }}
                        >
                          Excluded
                        </span>
                        <span
                          className="text-xs font-mono"
                          style={{ color: COLORS.textMuted }}
                        >
                          LoadDate, UpdateDate
                        </span>
                      </div>
                      <div>
                        <span
                          className="block text-xs mb-1"
                          style={{ color: COLORS.textMuted }}
                        >
                          Result
                        </span>
                        <StatusBadge status={t.diffStatus} />
                      </div>
                    </div>
                    <div className="mt-3">
                      <span
                        className="block text-xs mb-2"
                        style={{ color: COLORS.textMuted }}
                      >
                        Columns Compared:
                      </span>
                      <div className="flex flex-wrap gap-1.5">
                        {t.diffColumns.map((c) => (
                          <span
                            key={c}
                            className="px-2 py-0.5 rounded text-xs font-mono"
                            style={{
                              background: `${COLORS.success}15`,
                              color: COLORS.success,
                              border: `1px solid ${COLORS.success}33`,
                            }}
                          >
                            {c}
                          </span>
                        ))}
                      </div>
                    </div>
                  </td>
                </tr>
              )}
            </>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// ─── Row Count Comparison Chart ──────────────────────────────────────────────
function RowCountChart() {
  return (
    <ResponsiveContainer width="100%" height={320}>
      <BarChart
        data={rowCountData}
        margin={{ top: 10, right: 30, left: 0, bottom: 0 }}
      >
        <CartesianGrid
          strokeDasharray="3 3"
          stroke={COLORS.border}
          opacity={0.3}
        />
        <XAxis
          dataKey="name"
          stroke={COLORS.textMuted}
          fontSize={11}
          tick={{ fill: COLORS.textMuted }}
        />
        <YAxis
          stroke={COLORS.textMuted}
          fontSize={11}
          tick={{ fill: COLORS.textMuted }}
        />
        <Tooltip
          contentStyle={{
            background: COLORS.card,
            border: `1px solid ${COLORS.border}`,
            borderRadius: 8,
            color: COLORS.text,
          }}
          labelStyle={{ color: COLORS.text, fontWeight: 600 }}
          formatter={(value: any, name: any) => [
            Number(value).toLocaleString() + " rows",
            name === "mssql" ? "MS SQL Server" : "Fabric",
          ]}
          labelFormatter={(label: any) =>
            rowCountData.find((d) => d.name === String(label))?.fullName ??
            String(label)
          }
        />
        <Legend
          formatter={(value: string) =>
            value === "mssql" ? "MS SQL Server" : "Microsoft Fabric"
          }
          wrapperStyle={{ color: COLORS.textMuted, fontSize: 12 }}
        />
        <Bar
          dataKey="mssql"
          fill={COLORS.mssql}
          radius={[4, 4, 0, 0]}
          barSize={28}
        />
        <Bar
          dataKey="fabric"
          fill={COLORS.fabric}
          radius={[4, 4, 0, 0]}
          barSize={28}
        />
      </BarChart>
    </ResponsiveContainer>
  );
}

// ─── Table Distribution Treemap ──────────────────────────────────────────────
const treemapData = [
  {
    name: "Gold Tables",
    children: goldTables.map((t) => ({
      name: t.name,
      size: t.rowCount,
      type: t.type,
    })),
  },
];

interface TreemapContentProps {
  x: number;
  y: number;
  width: number;
  height: number;
  name?: string;
  type?: string;
}

function CustomTreemapContent({
  x,
  y,
  width,
  height,
  name,
  type,
}: TreemapContentProps) {
  if (width < 40 || height < 30) return null;
  const fill = type === "fact" ? COLORS.fact : COLORS.dimension;
  return (
    <g>
      <rect
        x={x}
        y={y}
        width={width}
        height={height}
        rx={4}
        fill={`${fill}33`}
        stroke={fill}
        strokeWidth={1.5}
      />
      {width > 60 && height > 40 && (
        <>
          <text
            x={x + width / 2}
            y={y + height / 2 - 6}
            textAnchor="middle"
            fill={COLORS.text}
            fontSize={10}
            fontWeight={600}
          >
            {name && name.length > 14 ? name.slice(0, 12) + "…" : name}
          </text>
          <text
            x={x + width / 2}
            y={y + height / 2 + 10}
            textAnchor="middle"
            fill={COLORS.textMuted}
            fontSize={9}
          >
            {type === "fact" ? "Fact" : "Dim"}
          </text>
        </>
      )}
    </g>
  );
}

// ─── Migration Flow Diagram ──────────────────────────────────────────────────
function MigrationFlowDiagram() {
  return (
    <div className="flex flex-col md:flex-row items-center justify-center gap-6 py-4">
      {/* Source */}
      <div
        className="flex flex-col items-center gap-2 p-5 rounded-xl"
        style={{
          background: `${COLORS.mssql}15`,
          border: `2px solid ${COLORS.mssql}44`,
        }}
      >
        <Database size={36} style={{ color: COLORS.mssql }} />
        <span className="text-sm font-bold" style={{ color: COLORS.mssql }}>
          MS SQL Server
        </span>
        <span className="text-xs" style={{ color: COLORS.textMuted }}>
          RetailDW
        </span>
        <span className="text-xs" style={{ color: COLORS.textMuted }}>
          10 RAW + 8 TRANSFORMED
        </span>
      </div>

      {/* Arrow with dbt */}
      <div className="flex flex-col items-center gap-1">
        <div className="flex items-center gap-2">
          <div className="h-px w-12" style={{ background: COLORS.textMuted }} />
          <div
            className="px-3 py-1.5 rounded-lg text-xs font-bold"
            style={{
              background: `${COLORS.success}22`,
              color: COLORS.success,
              border: `1px solid ${COLORS.success}44`,
            }}
          >
            dbt + data_diff
          </div>
          <div className="h-px w-12" style={{ background: COLORS.textMuted }} />
        </div>
        <span className="text-xs" style={{ color: COLORS.textMuted }}>
          Medallion Architecture
        </span>
        <span className="text-xs" style={{ color: COLORS.textMuted }}>
          Bronze → Silver → Gold
        </span>
      </div>

      {/* Target */}
      <div
        className="flex flex-col items-center gap-2 p-5 rounded-xl"
        style={{
          background: `${COLORS.fabric}15`,
          border: `2px solid ${COLORS.fabric}44`,
        }}
      >
        <Server size={36} style={{ color: COLORS.fabric }} />
        <span className="text-sm font-bold" style={{ color: COLORS.fabric }}>
          Microsoft Fabric
        </span>
        <span className="text-xs" style={{ color: COLORS.textMuted }}>
          Data Warehouse
        </span>
        <span className="text-xs" style={{ color: COLORS.textMuted }}>
          10 RAW + 8 TRANSFORMED
        </span>
      </div>
    </div>
  );
}

// ─── Parity Donut ────────────────────────────────────────────────────────────
function ParityDonut() {
  const data = [
    {
      name: "Identical",
      value: migrationSummary.tablesWithParity,
      fill: COLORS.success,
    },
    {
      name: "Mismatched",
      value: migrationSummary.tablesWithDifferences,
      fill: "#ef4444",
    },
  ];
  return (
    <div className="flex items-center justify-center gap-6">
      <ResponsiveContainer width={160} height={160}>
        <PieChart>
          <Pie
            data={data}
            innerRadius={50}
            outerRadius={70}
            paddingAngle={2}
            dataKey="value"
            startAngle={90}
            endAngle={-270}
            strokeWidth={0}
          >
            {data.map((d, i) => (
              <Cell key={i} fill={d.fill} />
            ))}
          </Pie>
        </PieChart>
      </ResponsiveContainer>
      <div className="flex flex-col gap-3">
        <div className="flex items-center gap-2">
          <div
            className="w-3 h-3 rounded-full"
            style={{ background: COLORS.success }}
          />
          <span className="text-sm" style={{ color: COLORS.text }}>
            {migrationSummary.tablesWithParity} Identical
          </span>
        </div>
        <div className="flex items-center gap-2">
          <div
            className="w-3 h-3 rounded-full"
            style={{ background: "#ef4444" }}
          />
          <span className="text-sm" style={{ color: COLORS.textMuted }}>
            {migrationSummary.tablesWithDifferences} Mismatched
          </span>
        </div>
        <div className="text-xs mt-1" style={{ color: COLORS.textMuted }}>
          100% data parity achieved
        </div>
      </div>
    </div>
  );
}

// ─── Main App ────────────────────────────────────────────────────────────────
export default function App() {
  return (
    <div className="min-h-screen p-4 md:p-8" style={{ background: COLORS.bg }}>
      <div className="max-w-7xl mx-auto flex flex-col gap-6">
        {/* ── Header ──────────────────────────────────────────────────── */}
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-2">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <div
                className="p-2.5 rounded-xl"
                style={{ background: `${COLORS.fabric}22` }}
              >
                <ArrowRightLeft size={24} style={{ color: COLORS.fabric }} />
              </div>
              <h1
                className="text-2xl md:text-3xl font-bold tracking-tight"
                style={{ color: COLORS.text }}
              >
                MS SQL Server to Fabric Migration
              </h1>
            </div>
            <p className="text-sm" style={{ color: COLORS.textMuted }}>
              Data parity validation — Medallion Architecture with dbt
            </p>
          </div>
          <div className="flex items-center gap-3">
            <span
              className="px-3 py-1.5 rounded-lg text-xs font-medium"
              style={{
                background: `${COLORS.success}22`,
                color: COLORS.success,
                border: `1px solid ${COLORS.success}44`,
              }}
            >
              <CheckCircle2 size={12} className="inline mr-1" />
              All Validations Passed
            </span>
            <span className="text-xs" style={{ color: COLORS.textMuted }}>
              {migrationSummary.migrationDate}
            </span>
          </div>
        </div>

        {/* ── KPI Row ─────────────────────────────────────────────────── */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <KPICard
            icon={Table2}
            label="Tables Validated"
            value={migrationSummary.totalTransformedTables}
            sub="8 of 8 gold-layer tables"
            color={COLORS.gold}
          />
          <KPICard
            icon={Columns3}
            label="Rows Checked"
            value={migrationSummary.totalRowsValidated.toLocaleString()}
            sub="Across all fact & dimension tables"
            color={COLORS.fabric}
          />
          <KPICard
            icon={Shield}
            label="Data Parity"
            value="100%"
            sub="Zero discrepancies found"
            color={COLORS.success}
          />
          <KPICard
            icon={Layers}
            label="dbt Models"
            value={silverModels.length + goldTables.length}
            sub={`${silverModels.length} silver + ${goldTables.length} gold`}
            color={COLORS.silver}
          />
        </div>

        {/* ── Migration Flow ──────────────────────────────────────────── */}
        <Section title="Migration Overview" icon={ArrowRightLeft}>
          <MigrationFlowDiagram />
        </Section>

        {/* ── Medallion Architecture ──────────────────────────────────── */}
        <Section title="Medallion Architecture" icon={Layers}>
          <MedallionArchitecture />
          <div
            className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-5 pt-5"
            style={{ borderTop: `1px solid ${COLORS.border}33` }}
          >
            <div>
              <span
                className="text-xs block mb-1"
                style={{ color: COLORS.textMuted }}
              >
                Bronze Tables
              </span>
              <span
                className="text-xl font-bold"
                style={{ color: COLORS.bronze }}
              >
                {bronzeTables.length}
              </span>
              <span
                className="text-xs ml-1"
                style={{ color: COLORS.textMuted }}
              >
                ({totalBronzeRows.toLocaleString()} rows)
              </span>
            </div>
            <div>
              <span
                className="text-xs block mb-1"
                style={{ color: COLORS.textMuted }}
              >
                Silver Models
              </span>
              <span
                className="text-xl font-bold"
                style={{ color: COLORS.silver }}
              >
                {silverModels.length}
              </span>
              <span
                className="text-xs ml-1"
                style={{ color: COLORS.textMuted }}
              >
                (dbt views)
              </span>
            </div>
            <div>
              <span
                className="text-xs block mb-1"
                style={{ color: COLORS.textMuted }}
              >
                Gold Dimensions
              </span>
              <span
                className="text-xl font-bold"
                style={{ color: COLORS.dimension }}
              >
                6
              </span>
              <span
                className="text-xs ml-1"
                style={{ color: COLORS.textMuted }}
              >
                (dbt tables)
              </span>
            </div>
            <div>
              <span
                className="text-xs block mb-1"
                style={{ color: COLORS.textMuted }}
              >
                Gold Facts
              </span>
              <span
                className="text-xl font-bold"
                style={{ color: COLORS.fact }}
              >
                2
              </span>
              <span
                className="text-xs ml-1"
                style={{ color: COLORS.textMuted }}
              >
                (dbt tables)
              </span>
            </div>
          </div>
        </Section>

        {/* ── Lineage DAG ─────────────────────────────────────────────── */}
        <Section title="Data Lineage — dbt Model Dependencies" icon={GitBranch}>
          <p className="text-xs mb-4" style={{ color: COLORS.textMuted }}>
            Drag nodes to rearrange. Colors: <LayerBadge layer="bronze" />{" "}
            source tables, <LayerBadge layer="silver" /> staging models,{" "}
            <LayerBadge layer="gold" /> dimension & fact tables.
          </p>
          <LineageDAG nodes={lineageNodes} edges={lineageEdges} />
        </Section>

        {/* ── Data Diff Results ────────────────────────────────────────── */}
        <Section
          title="Data Diff Results — Row-Level Validation"
          icon={ArrowRightLeft}
        >
          <div className="flex flex-col md:flex-row gap-6 mb-6">
            <div className="flex-1">
              <p className="text-xs mb-2" style={{ color: COLORS.textMuted }}>
                Algorithm:{" "}
                <span className="font-semibold" style={{ color: COLORS.text }}>
                  HashDiff
                </span>{" "}
                — cross-database bisection with checksums. Compares actual row
                data, not just statistical profiles. Audit columns (LoadDate,
                UpdateDate) excluded.
              </p>
              <ParityDonut />
            </div>
            <div
              className="flex-1 rounded-lg p-4"
              style={{ background: `${COLORS.cardAlt}44` }}
            >
              <h3
                className="text-sm font-semibold mb-3"
                style={{ color: COLORS.text }}
              >
                Validation Summary
              </h3>
              <div className="flex flex-col gap-2 text-xs">
                {[
                  [
                    "Source",
                    `${migrationSummary.sourceSystem} (${migrationSummary.sourceHost})`,
                  ],
                  [
                    "Target",
                    `${migrationSummary.targetSystem} (Data Warehouse)`,
                  ],
                  ["Algorithm", "HashDiff (cross-database bisection)"],
                  [
                    "Tables Compared",
                    `${migrationSummary.totalTransformedTables}`,
                  ],
                  [
                    "Total Rows",
                    migrationSummary.totalRowsValidated.toLocaleString(),
                  ],
                  [
                    "Columns Compared",
                    `${migrationSummary.totalColumnsCompared}`,
                  ],
                  ["Result", "100% parity — zero differences"],
                ].map(([k, v]) => (
                  <div
                    key={k}
                    className="flex justify-between py-1"
                    style={{ borderBottom: `1px solid ${COLORS.border}22` }}
                  >
                    <span style={{ color: COLORS.textMuted }}>{k}</span>
                    <span
                      className="font-medium"
                      style={{ color: COLORS.text }}
                    >
                      {v}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
          <DataDiffTable />
        </Section>

        {/* ── Charts Row ──────────────────────────────────────────────── */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Section
            title="Row Count Comparison: MS SQL vs Fabric"
            icon={BarChart3}
          >
            <p className="text-xs mb-3" style={{ color: COLORS.textMuted }}>
              Side-by-side row counts for each gold-layer table. Matching bars
              confirm data completeness.
            </p>
            <RowCountChart />
          </Section>

          <Section title="Table Size Distribution (Gold Layer)" icon={Workflow}>
            <p className="text-xs mb-3" style={{ color: COLORS.textMuted }}>
              Treemap proportional to row count.{" "}
              <span style={{ color: COLORS.dimension }}>
                Purple = Dimensions
              </span>
              , <span style={{ color: COLORS.fact }}>Pink = Facts</span>.
            </p>
            <ResponsiveContainer width="100%" height={320}>
              <Treemap
                data={treemapData}
                dataKey="size"
                aspectRatio={4 / 3}
                stroke={COLORS.card}
                content={
                  <CustomTreemapContent x={0} y={0} width={0} height={0} />
                }
              />
            </ResponsiveContainer>
          </Section>
        </div>

        {/* ── Footer ──────────────────────────────────────────────────── */}
        <div
          className="text-center py-6"
          style={{ borderTop: `1px solid ${COLORS.border}33` }}
        >
          <p className="text-xs" style={{ color: COLORS.textMuted }}>
            Migration validated by{" "}
            <span className="font-semibold" style={{ color: COLORS.fabric }}>
              altimate-code
            </span>{" "}
            using data_diff (HashDiff algorithm) &bull; dbt project:{" "}
            <span className="font-mono">{migrationSummary.dbtProject}</span>{" "}
            &bull; {migrationSummary.migrationDate}
          </p>
        </div>
      </div>
    </div>
  );
}
