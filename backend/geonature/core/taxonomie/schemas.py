from geonature.utils.env import MA

from .models import Taxref


class TaxrefSchema(MA.SQLAlchemyAutoSchema):
    class Meta:
        model = Taxref
        load_instance = True
        include_fk = True
