import pytask

from src.config import BLD
from src.config import SRC

# data = SRC / "original_data" / "ajrcomment.dta"
# prod = BLD / "data" / "ajrcomment_all.csv"


# @pytask.mark.r([str(x.resolve()) for x in [data, prod]])
# @pytask.mark.depends_on(["add_variables.r", data])
# @pytask.mark.produces(prod)
# def task_ajr_comment_data():
#     pass


data2 = [
    SRC / "original_data" / "SSSY_documentation.xls",
    SRC / "data_management" / "translate_data.py",
]

prod2 = [
    BLD / "data" / "data_specialist_type.csv",
    BLD / "data" / "data_claims_number.csv",
    BLD / "data" / "data_claims_details.csv",
    BLD / "data" / "data_claims.RData",
]


@pytask.mark.r([str(x.resolve()) for x in [*data2, *prod2]])
@pytask.mark.depends_on(["read_data.R", *data2])
@pytask.mark.produces(prod2)
def task_clean_claims_data():
    pass
