# GitHub iOS App Architecture Diagrams

This directory contains architecture design diagrams for the GitHub iOS app, created using Mermaid Markdown format.

## File Descriptions

- `Component-Diagram.mmd`: Application component architecture diagram, showing different layers and their dependencies
- `Class-Diagram.mmd`: Application class diagram, showing main classes and their relationships
- `Login-Sequence-Diagram.mmd`: Login process sequence diagram, detailing the flow of three login methods

## How to Preview These Diagrams

Since Mermaid is a text-based diagram format, you need to use tools that support Mermaid to preview these diagrams:

### Method 1: Using VS Code (Recommended)
1. Install VS Code editor
2. Install the "Markdown Preview Mermaid Support" extension
3. Open the MMD files
4. Press `Cmd+Shift+V` (Mac) or `Ctrl+Shift+V` (Windows) to preview

### Method 2: Using Online Editor
1. Visit [Mermaid Live Editor](https://mermaid.live/)
2. Copy the MMD file content to the left side of the editor
3. The rendered diagram will display on the right

### Method 3: Export to PNG/SVG Format
To export diagrams to image format, you can:

1. Use the Mermaid command line tool:
   ```bash
   # Install the tool
   npm install -g @mermaid-js/mermaid-cli
   
   # Convert to PNG
   mmdc -i Component-Diagram.mmd -o Component-Diagram.png
   mmdc -i Class-Diagram.mmd -o Class-Diagram.png
   mmdc -i Login-Sequence-Diagram.mmd -o Login-Sequence-Diagram.png
   ```

2. Or export using the online editor:
   - Render the diagram in [Mermaid Live Editor](https://mermaid.live/)
   - Click the "Export" button in the top right
   - Select PNG or SVG format to download

## Modifying Diagrams

To modify these architecture diagrams:
1. Edit the corresponding MMD file using a text editor
2. Preview the modified effect using the methods described above
3. Export updated images to update documentation

## Diagram Rendering Examples

Example of diagram rendering in README:

![Component Architecture Diagram](Component-Diagram.png)
![Class Diagram](Class-Diagram.png)
![Login Process Sequence Diagram](Login-Sequence-Diagram.png)

Note: Please ensure these PNG files are exported and placed in this directory for the image links in the README to display properly. 