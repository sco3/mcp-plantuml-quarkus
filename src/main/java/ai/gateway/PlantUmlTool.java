package ai.gateway;

import java.io.ByteArrayOutputStream;
import java.util.Base64;

import io.quarkiverse.mcp.server.ImageContent;
import io.quarkiverse.mcp.server.Tool;
import io.quarkiverse.mcp.server.ToolArg;
import net.sourceforge.plantuml.FileFormat;
import net.sourceforge.plantuml.FileFormatOption;
import net.sourceforge.plantuml.SourceStringReader;

public class PlantUmlTool {

    @Tool(description = "Renders a PlantUML string into a PNG image.")
    public ImageContent renderDiagram(
            @ToolArg(description = "The PlantUML source code (starting with @startuml and ending with @enduml).") String source)
            throws Exception {
        SourceStringReader reader = new SourceStringReader(source);
        ByteArrayOutputStream os = new ByteArrayOutputStream();

        reader.generateImage(os, new FileFormatOption(FileFormat.SVG));
        byte[] imageBytes = os.toByteArray();

        String base64Image = Base64.getEncoder().encodeToString(imageBytes);

        return new ImageContent(base64Image, "image/png");
    }
}