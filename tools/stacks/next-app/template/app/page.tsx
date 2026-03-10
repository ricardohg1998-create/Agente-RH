const shellStyle = {
  minHeight: "100vh",
  display: "grid",
  placeItems: "center",
  padding: "48px 24px",
};

const cardStyle = {
  maxWidth: "760px",
  background: "#fffdf8",
  border: "1px solid #d6d0c3",
  borderRadius: "24px",
  padding: "40px",
  boxShadow: "0 24px 80px rgba(31, 42, 36, 0.08)",
};

export default function HomePage() {
  return (
    <main style={shellStyle}>
      <section style={cardStyle}>
        <p style={{ letterSpacing: "0.18em", textTransform: "uppercase", fontSize: "0.78rem", color: "#6b7269" }}>
          Scaffold inicial
        </p>
        <h1 style={{ fontSize: "clamp(2.4rem, 6vw, 4.5rem)", lineHeight: 1.05, margin: "12px 0 18px" }}>
          __PROJECT_NAME__
        </h1>
        <p style={{ fontSize: "1.1rem", lineHeight: 1.7, marginBottom: "18px" }}>{`__PROJECT_VISION__`}</p>
        <p style={{ fontSize: "1rem", lineHeight: 1.6, color: "#475049" }}>
          Primer entregable previsto: <strong>__FIRST_DELIVERABLE__</strong>.
        </p>
      </section>
    </main>
  );
}
