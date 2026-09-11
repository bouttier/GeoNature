from geonature.utils.env import CONFIG_FILE
from geonature.utils.module import iter_modules_config

reload = True
reload_extra_files = [CONFIG_FILE] + list(iter_modules_config())
