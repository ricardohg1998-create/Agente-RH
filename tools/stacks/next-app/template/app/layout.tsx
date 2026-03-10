import type { ReactNode } from "react";

export const metadata = {
  title: "__PROJECT_NAME__",
  description: "__PROJECT_VISION__",
};

type RootLayoutProps = {
  children: ReactNode;
};

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="es">
      <body
        style={{
          margin: 0,
          fontFamily: "ui-sans-serif, system-ui, sans-serif",
          background: "#f6f4ee",
          color: "#1f2a24",
        }}
      >
        {children}
      </body>
    </html>
  );
}
