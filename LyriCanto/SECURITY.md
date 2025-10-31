# Security Policy

## 🔒 Supported Versions

Attualmente supportiamo con patch di sicurezza:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## 🐛 Reporting a Vulnerability

La sicurezza di LyriCanto è la nostra massima priorità.

### Come Segnalare

Se scopri una vulnerabilità di sicurezza, ti preghiamo di **NON** aprire un issue pubblico.

Invece, contattaci privatamente:

📧 **Email**: security@lyriforge.example

Includi:
1. Descrizione dettagliata della vulnerabilità
2. Passi per riprodurre
3. Impatto potenziale
4. Eventuali proof-of-concept (se sicuri)

### Cosa Aspettarsi

- ✅ **Conferma di ricezione** entro 48 ore
- 🔍 **Valutazione iniziale** entro 7 giorni
- 🛠️ **Piano di risoluzione** entro 30 giorni (per vulnerabilità critiche)
- 🏆 **Riconoscimento pubblico** (se desiderato) dopo la risoluzione

### Vulnerabilità in Scope

Accettiamo segnalazioni per:

- 🔑 Esposizione API key o credenziali
- 💉 Code injection vulnerabilities
- 🚪 Bypass di restrizioni di accesso
- 🔓 Keychain security issues
- 📂 File system traversal
- 🌐 Network security issues
- 🔐 Crittografia debole o mal implementata

### Out of Scope

Non consideriamo vulnerabilità:

- 🐛 Bug generici non legati alla sicurezza
- 📱 Social engineering attacks
- 🌐 Issues in dipendenze esterne (segnala direttamente a loro)
- 🖥️ Vulnerabilità che richiedono accesso fisico al device

## 🔐 Security Best Practices per Utenti

### Gestione API Key

✅ **DO:**
- Salva la chiave nel Keychain tramite l'app
- Usa variabili d'ambiente per sviluppo
- Ruota le chiavi periodicamente
- Usa chiavi diverse per dev/prod

❌ **DON'T:**
- Committare chiavi in Git
- Condividere chiavi via email/chat
- Usare la stessa chiave per più app
- Salvare chiavi in plain text

### Protezione Dati

✅ **DO:**
- Verifica di avere i diritti sui contenuti
- Usa audio/testi con licenze appropriate
- Mantieni backup dei progetti
- Cripta file sensibili

❌ **DON'T:**
- Processare contenuti protetti senza permesso
- Condividere progetti con dati sensibili
- Ignorare avvisi di licenza dell'app

### Network Security

✅ **DO:**
- Usa connessioni sicure (HTTPS)
- Verifica certificati SSL
- Monitora traffico anomalo

❌ **DON'T:**
- Usare reti WiFi pubbliche non sicure per operazioni sensibili
- Disabilitare validazione certificati
- Ignorare warning di sicurezza

## 🛡️ Security Features in LyriCanto

### Implemented

- 🔐 **Keychain Integration**: API key salvate in modo sicuro
- ✅ **Input Validation**: Sanitizzazione input utente
- 🔒 **HTTPS Only**: Tutte le chiamate API usano HTTPS
- 🛡️ **Sandboxing**: App sandbox-friendly
- 🔍 **Error Handling**: Gestione sicura degli errori
- 📋 **License Compliance**: Verifiche built-in per copyright

### Planned

- 🔐 Two-factor authentication per account premium
- 📊 Audit logging per operazioni sensibili
- 🔑 Key rotation automatica
- 🛡️ Enhanced sandboxing

## 📜 Privacy Policy

### Dati Raccolti

LyriCanto **NON raccoglie** dati utente per impostazione predefinita:

- ❌ Nessun tracking
- ❌ Nessuna analytics esterna
- ❌ Nessun invio di testi a server esterni (oltre Claude API)

### Dati Inviati a Claude API

Quando generi testi:
- ✅ Testo originale
- ✅ Parametri di configurazione
- ❌ Nessun dato personale
- ❌ Nessun file audio

Vedi [Anthropic Privacy Policy](https://www.anthropic.com/legal/privacy) per dettagli.

### Storage Locale

Dati salvati localmente:
- 📁 Progetti in `~/Documents/LyriCanto`
- 🔑 API key nel Keychain macOS
- ⚙️ Preferenze in UserDefaults

**Nessun dato lascia il tuo Mac** tranne le chiamate API necessarie.

## 🔄 Security Updates

Monitora questo repository per:
- 🔔 Security advisories
- 📦 Patch releases
- 📋 Security-related changelogs

Abilita le notifiche su GitHub per ricevere alert immediati.

## 🏆 Hall of Fame

Riconosciamo pubblicamente i security researchers che ci aiutano (con loro permesso):

*Nessuna vulnerabilità segnalata finora - sii il primo!*

## 📞 Contact

- 🔐 Security: security@lyriforge.example
- 💬 General: support@lyriforge.example
- 🐛 Bugs: GitHub Issues (solo non-security)

## 📚 Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Apple Security Guide](https://support.apple.com/guide/security/welcome/web)
- [Anthropic Security](https://www.anthropic.com/security)

---

**Grazie per aiutarci a mantenere LyriCanto sicuro! 🛡️**
