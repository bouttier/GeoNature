from geonature.utils.env import MA

from .models import TDatasets


class DatasetSchema(MA.SQLAlchemyAutoSchema):
    class Meta:
        model = TDatasets
        load_instance = True
        include_fk = True
