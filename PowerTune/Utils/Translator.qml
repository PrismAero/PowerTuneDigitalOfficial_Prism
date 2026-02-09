// * PowerTune Translator singleton
// * Provides translation functions for the entire application
pragma Singleton
import QtQuick 2.15
import "Translator.js" as TranslatorJS

QtObject {
    id: translator

    // * Translate text based on current language setting
    // * @param text - The key to translate
    // * @param language - The language code (en, de, jp, es, fr, ar)
    // * @returns The translated string or English fallback
    function translate(text, language) {
        return TranslatorJS.translate(text, language);
    }

    // * Shorthand alias for translate()
    function tr(text, language) {
        return translate(text, language);
    }
}
