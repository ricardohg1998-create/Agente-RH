import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { Project, Node } from "ts-morph";
import path from "path";

// Inicializamos ts-morph de forma generica
// Para un entorno real, aqui podriamos cargar el tsconfig raiz del repositorio original
const project = new Project();

const server = new Server(
  {
    name: "agente-rh-semantic-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "analyze_file_ast",
        description: "Analiza sintacticamente un archivo de TypeScript y devuelve sus exportaciones, interfaces y clases.",
        inputSchema: {
          type: "object",
          properties: {
            filePath: {
              type: "string",
              description: "Ruta absoluta o relativa al archivo TypeScript.",
            },
          },
          required: ["filePath"],
        },
      },
      {
        name: "get_symbol_references",
        description: "Encuentra donde se utiliza un simbolo o exportacion concreta a lo largo de todo el proyecto.",
        inputSchema: {
          type: "object",
          properties: {
            filePath: {
              type: "string",
              description: "Ruta al archivo que define originariamente el simbolo.",
            },
            symbolName: {
              type: "string",
              description: "Nombre del simbolo, tipo o funcion importada.",
            }
          },
          required: ["filePath", "symbolName"],
        },
      }
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  try {
    const { name, arguments: args } = request.params;
    
    if (!args) {
      throw new Error("Argumentos insuficientes.");
    }

    if (name === "analyze_file_ast") {
      const filePath = String(args.filePath);
      project.addSourceFileAtPathIfExists(filePath);
      const sourceFile = project.getSourceFile(filePath);
      
      if (!sourceFile) {
         return { content: [{ type: "text", text: `["ERROR"] Archivo no existe o no pudo ser interpretado: ${filePath}` }] };
      }
      
      const exports = Array.from(sourceFile.getExportedDeclarations().keys());
      const classes = sourceFile.getClasses().map(c => c.getName());
      const interfaces = sourceFile.getInterfaces().map(i => i.getName());
      
      const result = `----- REPORT AST -----\nArchivo: ${filePath}\nExportaciones (${exports.length}): ${exports.join(", ")}\nClases: ${classes.join(", ")}\nInterfaces: ${interfaces.join(", ")}\n----------------------`;
      return { content: [{ type: "text", text: result }] };
    }

    if (name === "get_symbol_references") {
      const filePath = String(args.filePath);
      const symbolName = String(args.symbolName);
      
      // Cargamos todo el codigo fuente de manera tosca para buscar referencias completas
      // En un entorno extremo esto puede tardar unos segundos la primera vez
      project.addSourceFilesAtPaths("../../**/*.ts?(x)"); 
      
      const sourceFile = project.getSourceFile(filePath) || project.addSourceFileAtPath(filePath);
      const exportedDecl = sourceFile.getExportedDeclarations().get(symbolName);
      
      if (!exportedDecl || exportedDecl.length === 0) {
         return { content: [{ type: "text", text: `["ERROR"] Simbolo no exportado o inexistente: ${symbolName}` }] };
      }
      
      const decl = exportedDecl[0];
      let refsStr = "";
      if (Node.isReferenceFindable(decl)) {
          const referencedSymbols = decl.findReferences();
          for (const refSymbol of referencedSymbols) {
             for (const ref of refSymbol.getReferences()) {
                 refsStr += `\n[Línea ${ref.getNode().getStartLineNumber()}] -> ${ref.getSourceFile().getFilePath()}`;
             }
          }
      }
      return { content: [{ type: "text", text: `----- REFERENCIAS DE ${symbolName} -----\n${refsStr}` }] };
    }

    throw new Error(`Herramienta MCP desconocida: ${name}`);
  } catch (error) {
    const err = error as Error;
    return {
      content: [{ type: "text", text: `[MCPServer Error Interno] ${err.message}` }],
      isError: true,
    };
  }
});

async function run() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Agente RH - Semantic MCP Server iniciado y enlazado por stdio.");
}

run().catch((error) => {
  console.error("Fallo critico en MCP Semantic Server:", error);
  process.exit(1);
});
