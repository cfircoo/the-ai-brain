---
name: brain-canvas
description: Create an Obsidian JSON Canvas visualization from vault content. Use when the user says "create a canvas", "visualize", "make a diagram", "map this out", "canvas view", or wants to create an Obsidian canvas file.
---

<objective>
Create an Obsidian JSON Canvas file that visually maps relationships between notes, concepts, processes, or ideas. The canvas uses the official Obsidian canvas format (.canvas files are JSON) and can be opened directly in Obsidian.
</objective>

<protocol>

## Step 1: Understand What to Visualize

Ask the user (or infer from context) what to map:
- A process or workflow (e.g., "map my content pipeline")
- Relationships between projects (e.g., "show how my projects connect")
- A specific topic across multiple notes (e.g., "visualize everything about authentication")
- A brainstorm or mind map (e.g., "map out ideas for X")

## Step 2: Gather Source Material

If visualizing vault content:

**With Obsidian CLI:**
```bash
obsidian search "<topic>" --format json
obsidian backlinks "<note-name>" --format json
```

**Without Obsidian CLI:**
- Search for relevant notes using Glob and Grep
- Read the most relevant ones to extract key concepts

## Step 3: Design the Canvas Layout

Plan the layout:
- **Left to right**: for processes/pipelines (input -> process -> output)
- **Hub and spoke**: for a central concept with related ideas
- **Grid**: for parallel items of equal weight
- **Hierarchical**: for org charts, taxonomy, or nested concepts

## Step 4: Build the Canvas JSON

Obsidian canvas format is a `.canvas` file (JSON):

```json
{
  "nodes": [
    {
      "id": "node1",
      "type": "text",
      "text": "## Title\nContent here",
      "x": 0,
      "y": 0,
      "width": 250,
      "height": 120,
      "color": "1"
    },
    {
      "id": "node2",
      "type": "file",
      "file": "Human/Projects/MyProject.md",
      "x": 350,
      "y": 0,
      "width": 250,
      "height": 120
    },
    {
      "id": "node3",
      "type": "link",
      "url": "https://example.com",
      "x": 700,
      "y": 0,
      "width": 250,
      "height": 120
    }
  ],
  "edges": [
    {
      "id": "edge1",
      "fromNode": "node1",
      "fromSide": "right",
      "toNode": "node2",
      "toSide": "left",
      "label": "leads to"
    }
  ]
}
```

**Node types:**
- `text` -- inline markdown text (use for concepts, labels, summaries)
- `file` -- link to an existing vault file (renders the note preview)
- `link` -- external URL card
- `group` -- container for grouping related nodes (add `label` field)

**Color values (Obsidian theme colors):**
- `"1"` = red, `"2"` = orange, `"3"` = yellow, `"4"` = green, `"5"` = cyan, `"6"` = purple

**Layout tips:**
- Space nodes at least 50px apart
- Standard node size: 250x120 for text, 400x300 for file previews
- Group containers: set x/y to encompass children, add padding of 50px

## Step 5: Save the Canvas

Save to `Machine/Canvases/{descriptive-name}.canvas`

Create the directory if it doesn't exist.

**With Obsidian CLI:** After saving, run:
```bash
obsidian open "Machine/Canvases/{name}.canvas"
```
to open it immediately in Obsidian.

## Step 6: Report

Tell the user:
- Where the canvas was saved
- How many nodes and edges it contains
- How to open it (if Obsidian CLI not used)

</protocol>

<rules>
- Canvas files must be valid JSON -- validate before saving
- Use `file` type nodes when the note already exists in the vault (creates live preview)
- Use `text` type nodes for new content or concepts not yet in a note
- Keep labels concise (edge labels max 30 chars)
- Don't create canvases with more than 30 nodes without asking the user first -- offer to break into sub-canvases
- Save to `Machine/Canvases/` not `Human/` -- canvases are AI-generated output
</rules>

<success_criteria>
- Valid JSON canvas file created
- File saved to Machine/Canvases/
- Canvas opened in Obsidian (if CLI available)
- Layout is logical and readable (not overlapping nodes)
- Edges have meaningful labels
</success_criteria>
