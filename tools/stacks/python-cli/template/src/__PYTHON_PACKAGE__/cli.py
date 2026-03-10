from __future__ import annotations

import argparse


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="__PROJECT_SLUG__",
        description="__PROJECT_NAME__ - __FIRST_DELIVERABLE__",
    )
    parser.add_argument(
        "--deliverable",
        default="__FIRST_DELIVERABLE__",
        help="Entregable actual que se quiere mostrar.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    print(f"Proyecto: __PROJECT_NAME__")
    print(f"Vision: __PROJECT_VISION__")
    print(f"Entregable: {args.deliverable}")
    return 0
