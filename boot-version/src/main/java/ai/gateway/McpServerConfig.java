package ai.gateway;

import io.modelcontextprotocol.server.McpServer;
import io.modelcontextprotocol.server.McpSyncServer;
import io.modelcontextprotocol.server.transport.StdioServerTransport;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class McpServerConfig {

    @Value("${mcp.server.name:plantuml-mcp-server}")
    private String serverName;

    @Value("${mcp.server.version:1.0.0}")
    private String serverVersion;

    @Bean
    public McpSyncServer mcpSyncServer() {
        StdioServerTransport transport = new StdioServerTransport();

        McpServer.SyncSpecification spec = McpServer.sync(transport)
            .serverInfo(serverName, serverVersion);

        return spec.build();
    }
}
