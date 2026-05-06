import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { Project, Node } from "ts-morph";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

// Resolucion segura de rutas para no escanear C: por error
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "../../../../");

let projectName = "agente-rh-semantic-server";
try {
  const pkg = JSON.parse(fs.readFileSync(path.join(repoRoot, "package.json"), "utf-8"));
  if (pkg.name) projectName = pkg.name + "-semantic";
} catch (e) {
  // Fallback
}

// Inicializamos ts-morph de forma generica
// Usamos cache y configuracion basica
const project = new Project({
  skipFileDependencyResolution: true, // Mas ligero
});

const server = new Server(
  {
    name: projectName,
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
      const absolutePath = path.isAbsolute(filePath) ? filePath : path.join(repoRoot, filePath);
      project.addSourceFileAtPathIfExists(absolutePath);
      const sourceFile = project.getSourceFile(absolutePath);
      
      if (!sourceFile) {
         return { content: [{ type: "text", text: `["ERROR"] Archivo no existe o no pudo ser interpretado: ${absolutePath}` }] };
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
      // Solo cargamos si no tenemos archivos ya
      if (project.getSourceFiles().length === 0) {
        // Ignoramos librerias y archivos pesados para que resuelva rapido
        project.addSourceFilesAtPaths([
          path.join(repoRoot, "src/**/*.ts?(x)"),
          path.join(repoRoot, "app/**/*.ts?(x)"),
          path.join(repoRoot, "components/**/*.ts?(x)"),
          path.join(repoRoot, "lib/**/*.ts?(x)")
        ]);
      }
      
      const absolutePath = path.isAbsolute(filePath) ? filePath : path.join(repoRoot, filePath);
      const sourceFile = project.getSourceFile(absolutePath) || project.addSourceFileAtPath(absolutePath);
      let exportedDecl = sourceFile.getExportedDeclarations().get(symbolName);
      
      if (!exportedDecl || exportedDecl.length === 0) {
        // Fallback: si el simbolo no es el identificador exportado (ej. es 'default'), 
        // buscamos si el identificador local de alguna exportacion coincide con el nombre pedido
        const allExports = sourceFile.getExportedDeclarations();
        for (const [exportName, decls] of allExports.entries()) {
           for (const decl of decls) {
              if ("getName" in decl && typeof (decl as any).getName === "function" && (decl as any).getName() === symbolName) {
                 exportedDecl = [decl];
                 break;
              }
           }
           if (exportedDecl && exportedDecl.length > 0) break;
        }
      }

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
