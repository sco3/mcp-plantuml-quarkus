package ai.gateway;

import java.io.ByteArrayOutputStream;
import java.util.Base64;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.quarkiverse.mcp.server.ImageContent;
import io.quarkiverse.mcp.server.Tool;
import io.quarkiverse.mcp.server.ToolArg;
import net.sourceforge.plantuml.FileFormat;
import net.sourceforge.plantuml.FileFormatOption;
import net.sourceforge.plantuml.SourceStringReader;

public class PlantUmlTool {

    private static final Logger LOG = LoggerFactory.getLogger(PlantUmlTool.class);

    @Tool(description = "Renders a PlantUML string into a SVG image.")
    public ImageContent renderDiagram(
            @ToolArg(description = "The PlantUML source code (starting with @startuml and ending with @enduml).") String source)
            throws Exception {
        SourceStringReader reader = new SourceStringReader(source);
        ByteArrayOutputStream os = new ByteArrayOutputStream();

        reader.generateImage(os, new FileFormatOption(FileFormat.SVG));
        byte[] imageBytes = os.toByteArray();

        String base64Image = Base64.getEncoder().encodeToString(imageBytes);
        LOG.info("Generated SVG image of size {} bytes.", imageBytes.length);

        return new ImageContent(base64Image, "image/svg");
    }
}