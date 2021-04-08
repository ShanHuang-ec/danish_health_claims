"""
    Translate a string input from danish into english.
    conda list -e > requirements.txt #Save all the info about packages to your folder
"""

# Import the library
import pandas as pd
from google_trans_new import google_translator


def translate_da_to_en_str(danish_text):
    assert isinstance(danish_text, str) == True

    translator = google_translator()
    translate_text = translator.translate(danish_text, lang_src="da", lang_tgt="en")
    return translate_text


# translate panda dataframe column (doesn't work with R)
# def translate_da_to_en(df, danish_var):
#    translate_df_column = df['danish_var'].map(translate_da_to_eng).to_frame()
#    return translate_df_column

# d = {'col1': ["jeg", "ja"], 'col2': ["mig", "nej"]}
# df = pd.DataFrame(data=d)
# translate_da_to_en_column(df['col1'])
