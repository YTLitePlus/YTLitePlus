# Testing Guide - iOS SDK 18.5 Upgrade

## 🧪 Testing Checklist

### 1. GitHub Actions Workflow Test

#### Accesso al Workflow
1. Vai su: https://github.com/Nixde/YTLitePlusFork/actions
2. Clicca su "Build and Release YTLitePlus" nel menu laterale
3. Clicca su "Run workflow" (pulsante in alto a destra)

#### Configurazione Test Build
```yaml
Branch: upgrade-sdk-26-native-support
SDK Version: 18.5 (default)
YouTube IPA URL: [Your decrypted YouTube IPA URL]
Bundle ID: com.google.ios.youtube (default)
App Name: YouTube (default)
Upload Artifact: true (per scaricare l'IPA)
Catbox Upload: false (opzionale)
Create Release: false (per il test)
```

#### Cosa Verificare Durante la Build
- ✅ Step "Download iOS SDK" scarica iOS 18.5 SDK
- ✅ Step "Configure SDK Environment for iOS 18.5" imposta le variabili
- ✅ Output mostra: "Using SDK: .../iPhoneOS18.5.sdk"
- ✅ Step "Build Package" completa senza errori
- ✅ Nessun errore tipo: "could not build module '_Builtin_float'"
- ✅ Artifact generato (YTLitePlus_X.X.X_5.0.1.ipa)

#### Tempi Attesi
- Download SDK: 1-2 min (prima volta), 0s (cache hit)
- Build Package: 1-2 min
- Totale: ~10-15 min

### 2. Test dell'IPA Generata

#### Download
1. Alla fine della build, vai su "Artifacts" in fondo alla pagina
2. Scarica: `YTLitePlus_[version]_5.0.1.ipa`

#### Installazione
**Metodo 1 - AltStore**:
```
1. Apri AltStore sul tuo dispositivo
2. Clicca su "My Apps"
3. Clicca sul "+" in alto
4. Seleziona l'IPA scaricato
5. Attendi l'installazione
```

**Metodo 2 - Sideloadly**:
```
1. Apri Sideloadly
2. Connetti dispositivo iOS
3. Trascina l'IPA in Sideloadly
4. Inserisci Apple ID
5. Click "Start"
```

#### Verifica Funzionalità
Dopo l'installazione su iOS 18.x, testa:

- [ ] App si apre senza crash
- [ ] YouTube video si riproduce correttamente
- [ ] Background playback funziona
- [ ] PiP (Picture in Picture) funziona
- [ ] Settings → YTLitePlus accessibili
- [ ] iSponsorBlock attivo (salta sponsor)
- [ ] Return YouTube Dislikes mostra dislike
- [ ] OLED Dark Mode funziona
- [ ] Download di video funziona
- [ ] Impostazioni tweaks salvate correttamente

### 3. Test Locale (Opzionale)

Se hai macOS con Theos installato:

```bash
# 1. Checkout del branch
git checkout upgrade-sdk-26-native-support

# 2. Download SDK 18.5
cd $THEOS/sdks
git clone -n --depth=1 --filter=tree:0 https://github.com/arichornlover/sdks/
cd sdks
git sparse-checkout set --no-cone iPhoneOS18.5.sdk
git checkout
mv iPhoneOS18.5.sdk $THEOS/sdks/
cd ../..
rm -rf sdks

# 3. Setup variabili
export SDKROOT=$THEOS/sdks/iPhoneOS18.5.sdk
export EXTRA_CFLAGS="-fmodules-validate-once-per-build-session"

# 4. Build
make clean
make package SIDELOAD=1 THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1

# 5. Verifica output
ls -lh packages/*.ipa
```

#### Verifica Errori di Compilazione
Non devono apparire:
- ❌ `module '_c_standard_library_obsolete' requires feature...`
- ❌ `fatal error: could not build module '_Builtin_float'`
- ❌ `fatal error: could not build module 'CoreFoundation'`

Devono apparire:
- ✅ `==> Building...`
- ✅ `==> Signing...`
- ✅ `==> Package complete`

### 4. Test di Compatibilità SDK

#### Verifica SDK Detection
Durante la build, controlla il log per:
```
Using SDK: /path/to/theos/sdks/iPhoneOS18.5.sdk
SDKROOT is set to: /path/to/theos/sdks/iPhoneOS18.5.sdk
Building with iOS SDK 18.5
```

#### Verifica Flags
```
EXTRA_CFLAGS is set to: -fmodules-validate-once-per-build-session
```

### 5. Regression Testing

#### Confronto con SDK 17.5
Se possibile, compila anche con SDK 17.5 per confronto:
- Dimensione IPA simile (±5%)
- Funzionalità identiche
- Nessuna regressione

#### Test su Diverse Versioni iOS
- [ ] iOS 18.5 (latest)
- [ ] iOS 18.0
- [ ] iOS 17.x (backward compatibility)
- [ ] iOS 16.x (se possibile)

### 6. Performance Testing

#### Metriche da Verificare
- **Tempo Build**: ~10-15 min (normale)
- **Dimensione IPA**: ~100-150 MB (normale)
- **Tempo Installazione**: 2-5 min (normale)
- **RAM Usage**: ~300-500 MB (normale per YouTube)
- **CPU Usage**: Normale, no spike anomali

### 7. Error Handling Test

#### Test Scenario Negativi
1. **SDK Non Disponibile**: Rimuovi cache, verifica download automatico
2. **URL IPA Invalido**: Verifica che fallisca gracefully
3. **Make Error**: Introduci errore sintassi, verifica error reporting

## ✅ Success Criteria

La build è considerata **SUCCESSFUL** se:

1. ✅ Workflow GitHub Actions completa senza errori
2. ✅ IPA è generata e scaricabile
3. ✅ IPA si installa su iOS 18 device
4. ✅ App si apre e funziona correttamente
5. ✅ Tutte le funzionalità tweaks funzionano
6. ✅ Nessun crash o errore runtime
7. ✅ Performance normale (no lag)
8. ✅ Dimensione IPA ragionevole

## 🐛 Known Issues & Workarounds

### Issue 1: SDK Download Lento
**Workaround**: SDK viene cachato dopo primo download

### Issue 2: IPA Troppo Grande
**Verifica**: Dimensione normale è ~100-150 MB
**Causa**: Se >200 MB, potrebbe essere problema di stripping

### Issue 3: Catbox Upload Fallisce
**Workaround**: Usa Artifact upload invece

## 📊 Test Results Template

Usa questo template per documentare i risultati:

```markdown
## Test Results - iOS SDK 18.5 Upgrade

**Date**: 2026-02-04
**Branch**: upgrade-sdk-26-native-support
**Tester**: [Your Name]

### GitHub Actions Build
- Status: ✅ Success / ❌ Failed
- Build Time: X minutes
- SDK Used: iOS 18.5
- Errors: None / [List errors]

### IPA Installation
- Device: iPhone [Model]
- iOS Version: 18.x
- Installation Method: AltStore / Sideloadly
- Status: ✅ Success / ❌ Failed

### Functionality Tests
- [✅/❌] App Launch
- [✅/❌] Video Playback
- [✅/❌] Background Playback
- [✅/❌] PiP
- [✅/❌] iSponsorBlock
- [✅/❌] Return YouTube Dislikes
- [✅/❌] Settings Access

### Performance
- RAM Usage: X MB
- Launch Time: X seconds
- Overall: Good / Acceptable / Poor

### Recommendation
- [✅] Ready to merge
- [⏳] Needs more testing
- [❌] Issues found, don't merge
```

## 🚀 Next Steps After Testing

1. **Se tutti i test passano**:
   - Documenta risultati
   - Crea Pull Request
   - Richiedi review
   - Merge nel main branch

2. **Se ci sono problemi**:
   - Documenta errori nel GitHub Issue
   - Analizza log di build
   - Applica fix nel branch
   - Re-test

3. **Dopo Merge**:
   - Monitora build successive
   - Raccogli feedback utenti
   - Aggiorna documentazione se necessario

---

**Good Luck! 🎉**
