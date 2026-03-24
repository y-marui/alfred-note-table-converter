"""Workflow logger that writes to Alfred's standard log location.

Log path: ~/Library/Logs/Alfred/Workflow/<bundle_id>.log

Alfred displays workflow logs in the debugger (⌘D while Alfred is open).
Outside Alfred, logs go to stderr as a fallback.
"""

from __future__ import annotations

import logging
import os
import sys
from pathlib import Path


def _log_path() -> Path | None:
    bundle_id = os.environ.get("alfred_workflow_bundleid")
    if not bundle_id:
        return None
    log_dir = Path.home() / "Library" / "Logs" / "Alfred" / "Workflow"
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / f"{bundle_id}.log"


def get_logger(name: str = "workflow") -> logging.Logger:
    """Return a configured logger for the workflow.

    Args:
        name: Logger name (use __name__ for module-level loggers).

    Example::

        from alfred.logger import get_logger
        log = get_logger(__name__)
        log.info("starting search: %s", query)
    """
    logger = logging.getLogger(name)

    if logger.handlers:
        return logger

    logger.setLevel(logging.DEBUG)
    fmt = logging.Formatter(
        "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
    )

    log_path = _log_path()
    handler: logging.Handler
    if log_path:
        try:
            handler = logging.FileHandler(str(log_path), encoding="utf-8")
        except OSError:
            # Log dir not writable (sandbox, permissions) — fall back to stderr
            handler = logging.StreamHandler(sys.stderr)
    else:
        handler = logging.StreamHandler(sys.stderr)

    handler.setFormatter(fmt)
    logger.addHandler(handler)

    return logger
