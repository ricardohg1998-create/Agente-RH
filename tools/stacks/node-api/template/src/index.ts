import Fastify from "fastify";

const app = Fastify({
  logger: true,
});

app.get("/health", async () => {
  return {
    status: "ok",
    service: "__PROJECT_NAME__",
  };
});

app.get("/", async () => {
  return {
    project: "__PROJECT_NAME__",
    deliverable: "__FIRST_DELIVERABLE__",
    vision: "__PROJECT_VISION__",
  };
});

const port = Number(process.env.PORT ?? 3000);

async function start() {
  try {
    await app.listen({ port, host: "0.0.0.0" });
    app.log.info(`Servidor listo en http://localhost:${port}`);
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
}

start();
