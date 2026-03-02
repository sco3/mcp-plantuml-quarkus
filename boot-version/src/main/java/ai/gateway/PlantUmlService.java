package ai.gateway;

import io.modelcontextprotocol.server.McpSyncServer;
import io.modelcontextprotocol.spec.McpSchema;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.List;
import java.util.Map;

import net.sourceforge.plantuml.FileFormat;
import net.sourceforge.plantuml.FileFormatOption;
import net.sourceforge.plantuml.SourceStringReader;

@Service
public class PlantUmlService {

    private final McpSyncServer mcpServer;

    public PlantUmlService(McpSyncServer mcpServer) {
        this.mcpServer = mcpServer;
    }

    @PostConstruct
    public void init() {
        // Define the tool with proper JSON schema
        Map<String, Object> properties = Map.of(
            "source", Map.of(
                "type", "string",
                "description", "The PlantUML source code (starting with @startuml and ending with @enduml)."
            )
        );
        
        Map<String, Object> inputSchema = Map.of(
            "type", "object",
            "properties", properties,
            "required", List.of("source")
        );

        McpSchema.Tool renderTool = new McpSchema.Tool(
            "render_diagram",
            "Renders a PlantUML string into a SVG image.",
            inputSchema
        );

        // Register the tool
        mcpServer.addTool(renderTool, this::renderDiagram);
    }

    private McpSchema.CallToolResult renderDiagram(McpSchema.CallToolRequest request) {
        try {
            String source = (String) request.arguments().get("source");
            
            SourceStringReader reader = new SourceStringReader(source);
            ByteArrayOutputStream os = new ByteArrayOutputStream();

            reader.generateImage(os, new FileFormatOption(FileFormat.SVG));
            byte[] imageBytes = os.toByteArray();

            String base64Image = Base64.getEncoder().encodeToString(imageBytes);

            // Create image content as text with data URI
            McpSchema.TextContent textContent = new McpSchema.TextContent(
                "data:image/svg+xml;base64," + base64Image
            );

            return new McpSchema.CallToolResult(
                List.of(textContent),
                false
            );
        } catch (Exception e) {
            McpSchema.TextContent errorContent = new McpSchema.TextContent(
                "Error rendering diagram: " + e.getMessage()
            );
            return new McpSchema.CallToolResult(
                List.of(errorContent),
                true
            );
        }
    }
}
