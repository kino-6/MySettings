import logging

log = logging.getLogger(__name__)


def sync(records):
    if not records:
        log.warning("sync called with no records")
        return 0
    return len(records)
