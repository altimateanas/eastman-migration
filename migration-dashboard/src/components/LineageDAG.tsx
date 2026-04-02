import { useEffect, useRef } from "react";
import * as d3 from "d3";
import type { LineageNode, LineageEdge } from "../data/migration-data";

const LAYER_COLORS: Record<string, { fill: string; stroke: string }> = {
  bronze: { fill: "#cd7f3222", stroke: "#cd7f32" },
  silver: { fill: "#94a3b822", stroke: "#94a3b8" },
  gold: { fill: "#fbbf2422", stroke: "#fbbf24" },
};

// Assign fixed x positions per layer for a left-to-right layout
const LAYER_X: Record<string, number> = {
  bronze: 0.15,
  silver: 0.5,
  gold: 0.85,
};

interface SimNode extends LineageNode {
  x?: number;
  y?: number;
  fx?: number | null;
  fy?: number | null;
  vx?: number;
  vy?: number;
}

interface SimLink {
  source: string | SimNode;
  target: string | SimNode;
}

export function LineageDAG({
  nodes,
  edges,
}: {
  nodes: LineageNode[];
  edges: LineageEdge[];
}) {
  const svgRef = useRef<SVGSVGElement>(null);

  useEffect(() => {
    if (!svgRef.current) return;
    const containerWidth = svgRef.current.parentElement?.clientWidth || 900;
    const width = containerWidth;
    // Make canvas tall enough: largest layer has 10 nodes, need ~60px each + padding
    const height = 700;

    const svg = d3
      .select(svgRef.current)
      .attr("width", width)
      .attr("height", height);
    svg.selectAll("*").remove();

    // Defs for arrowhead
    const defs = svg.append("defs");
    defs
      .append("marker")
      .attr("id", "lineage-arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 58)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5")
      .attr("fill", "#475569");

    // Create a container group for zoom/pan
    const container = svg.append("g");

    // Add zoom behavior
    const zoom = d3
      .zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.4, 2.5])
      .on("zoom", (event) => {
        container.attr("transform", event.transform);
      });

    svg.call(zoom);

    // Reset zoom button area (rendered outside the zoom container)
    const resetGroup = svg.append("g").style("cursor", "pointer");
    resetGroup
      .append("rect")
      .attr("x", width - 100)
      .attr("y", 8)
      .attr("width", 90)
      .attr("height", 26)
      .attr("rx", 6)
      .attr("fill", "#334155")
      .attr("stroke", "#475569")
      .attr("stroke-width", 1);
    resetGroup
      .append("text")
      .attr("x", width - 55)
      .attr("y", 25)
      .attr("text-anchor", "middle")
      .attr("fill", "#94a3b8")
      .attr("font-size", 10)
      .attr("font-family", "'Inter', system-ui, sans-serif")
      .text("Reset Zoom");
    resetGroup.on("click", () => {
      svg.transition().duration(500).call(zoom.transform, d3.zoomIdentity);
    });

    // Copy data for D3 mutation
    const nodesCopy: SimNode[] = nodes.map((n) => ({
      ...n,
      x: LAYER_X[n.layer] * width,
      y: undefined,
    }));
    const linksCopy: SimLink[] = edges.map((e) => ({ ...e }));

    // Distribute nodes vertically within each layer
    const layerGroups: Record<string, SimNode[]> = {};
    nodesCopy.forEach((n) => {
      if (!layerGroups[n.layer]) layerGroups[n.layer] = [];
      layerGroups[n.layer].push(n);
    });

    const topPadding = 60; // leave space for layer labels
    const usableHeight = height - topPadding - 20;

    Object.values(layerGroups).forEach((group) => {
      const spacing = usableHeight / (group.length + 1);
      group.forEach((n, i) => {
        n.y = topPadding + spacing * (i + 1);
        n.fx = LAYER_X[n.layer] * width;
      });
    });

    const sim = d3
      .forceSimulation(nodesCopy as d3.SimulationNodeDatum[])
      .force(
        "link",
        d3
          .forceLink(linksCopy)
          .id((d: any) => d.id)
          .distance(160)
          .strength(0.3),
      )
      .force("charge", d3.forceManyBody().strength(-100))
      .force("y", d3.forceY(height / 2).strength(0.01))
      .force("collision", d3.forceCollide().radius(28))
      .alphaDecay(0.03);

    // Layer background columns (subtle)
    [
      { x: LAYER_X.bronze, color: "#cd7f32" },
      { x: LAYER_X.silver, color: "#94a3b8" },
      { x: LAYER_X.gold, color: "#fbbf24" },
    ].forEach((l) => {
      container
        .append("rect")
        .attr("x", l.x * width - 65)
        .attr("y", topPadding - 5)
        .attr("width", 130)
        .attr("height", usableHeight + 10)
        .attr("rx", 8)
        .attr("fill", `${l.color}06`)
        .attr("stroke", `${l.color}15`)
        .attr("stroke-width", 1);
    });

    // Layer header labels
    const layerLabels = [
      {
        label: "BRONZE",
        sub: "RAW Sources",
        x: LAYER_X.bronze,
        color: "#cd7f32",
      },
      {
        label: "SILVER",
        sub: "Staging (dbt)",
        x: LAYER_X.silver,
        color: "#94a3b8",
      },
      { label: "GOLD", sub: "Dims & Facts", x: LAYER_X.gold, color: "#fbbf24" },
    ];
    layerLabels.forEach((l) => {
      container
        .append("text")
        .attr("x", l.x * width)
        .attr("y", 24)
        .attr("text-anchor", "middle")
        .attr("fill", l.color)
        .attr("font-size", 12)
        .attr("font-weight", 700)
        .attr("opacity", 0.7)
        .text(l.label);
      container
        .append("text")
        .attr("x", l.x * width)
        .attr("y", 40)
        .attr("text-anchor", "middle")
        .attr("fill", "#64748b")
        .attr("font-size", 9)
        .text(l.sub);
    });

    // Links
    const linkSel = container
      .append("g")
      .selectAll("path")
      .data(linksCopy)
      .join("path")
      .attr("fill", "none")
      .attr("stroke", "#47556966")
      .attr("stroke-width", 1.2)
      .attr("marker-end", "url(#lineage-arrow)");

    // Node groups
    const nodeSel = container
      .append("g")
      .selectAll<SVGGElement, SimNode>("g")
      .data(nodesCopy)
      .join("g")
      .style("cursor", "grab")
      .call(
        d3
          .drag<SVGGElement, SimNode>()
          .on("start", (e, d: any) => {
            if (!e.active) sim.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
          })
          .on("drag", (e, d: any) => {
            d.fx = e.x;
            d.fy = e.y;
          })
          .on("end", (e, d: any) => {
            if (!e.active) sim.alphaTarget(0);
            // Keep x fixed to layer but release y
            d.fx = LAYER_X[d.layer] * width;
            d.fy = null;
          }),
      );

    // Node rectangles
    nodeSel
      .append("rect")
      .attr("x", -52)
      .attr("y", -16)
      .attr("width", 104)
      .attr("height", 32)
      .attr("rx", 6)
      .attr("fill", (d) => LAYER_COLORS[d.layer].fill)
      .attr("stroke", (d) => LAYER_COLORS[d.layer].stroke)
      .attr("stroke-width", 1.5);

    // Type indicator dot
    nodeSel
      .append("circle")
      .attr("cx", -42)
      .attr("cy", 0)
      .attr("r", 3)
      .attr("fill", (d) => {
        switch (d.type) {
          case "source":
            return "#cd7f32";
          case "staging":
            return "#94a3b8";
          case "dimension":
            return "#818cf8";
          case "fact":
            return "#f472b6";
          default:
            return "#94a3b8";
        }
      });

    // Node labels
    nodeSel
      .append("text")
      .attr("text-anchor", "middle")
      .attr("dy", "0.35em")
      .attr("x", 4)
      .attr("font-size", 9)
      .attr("fill", "#e2e8f0")
      .attr("font-family", "'Inter', system-ui, sans-serif")
      .text((d) =>
        d.label.length > 14 ? d.label.slice(0, 13) + "…" : d.label,
      );

    // Tooltip on hover
    nodeSel
      .append("title")
      .text((d) => `${d.label}\nLayer: ${d.layer}\nType: ${d.type}`);

    // Tick
    sim.on("tick", () => {
      // Clamp y to keep nodes within the visible area
      nodesCopy.forEach((d: any) => {
        d.y = Math.max(topPadding + 20, Math.min(height - 20, d.y));
      });

      linkSel.attr("d", (d: any) => {
        const sx = d.source.x;
        const sy = d.source.y;
        const tx = d.target.x;
        const ty = d.target.y;
        const mx = (sx + tx) / 2;
        return `M${sx},${sy} C${mx},${sy} ${mx},${ty} ${tx},${ty}`;
      });

      nodeSel.attr("transform", (d: any) => `translate(${d.x},${d.y})`);
    });

    return () => {
      sim.stop();
    };
  }, [nodes, edges]);

  return (
    <div
      className="w-full rounded-lg relative"
      style={{ background: "#0f172a88", minHeight: 700 }}
    >
      <div className="absolute top-2 left-3 flex items-center gap-2 z-10">
        <span
          className="text-xs px-2 py-1 rounded"
          style={{ background: "#334155", color: "#94a3b8" }}
        >
          Scroll to zoom &bull; Drag to pan
        </span>
      </div>
      <svg ref={svgRef} className="w-full" style={{ minHeight: 700 }} />
    </div>
  );
}
