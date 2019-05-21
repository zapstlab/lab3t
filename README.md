## UWAGA: poniższy tekst pomocy nie jest już spójny z tekstem w gałęzi master - aktualna wersja tekstu jest tylko w master.

# Zarządzanie OpenStack przez  cloudify

Celem tego ćwiczenia jet skonfigurowane Cloudify do pracy z OpenStack, a następnie uruchomienie i przygotowanie Blueprintu, który zainstaluje serwer Apache Tomcat na maszynie wirtualnej, a nastepnie przetestuje jego działanie z poziomu drugiej maszyny wirtualnej z prostym klientem HTTP.

Ćwiczenie pokazę w jaki sposób Cloudiy w OpenStack:
- tworzy grupy zabezpieczeń
- tworzy sieci
- tworzy routery
- tworzy maszyny wirtualne
- jak uruchamiać skrypty konfiguracyjne na maszynach wirtualnych

Uprzednio należy również skonfigurować dostęp Cloudify do OpenStack podając parametry dostępu do OpenStack pozyskane w pierwszej części ćwiczenia.

### KROK 1: Konfiguracja OpenStack w Cloudify
Z użyciem polecenia cfy należy ustawić tzw. secret values w Cloudify, które będą przechowywać parametry autentykacji Cloudify w OpenStack

```
cfy secrets list
cfy secrets create os_username -s <username>
cfy secrets create os_password -s <password>
cfy secrets create os_tenant_name -s <project name>
cfy secrets create os_keystone_url -s <url>
cfy secrets create os_region -s <region name>

cfy secrets list
cfy secrets get os_keystone_url

cfy secrets create os_username -s rajewluk
cfy secrets create os_password -s t6ygfr5
cfy secrets create os_tenant_name -s cloudify-test
cfy secrets create os_keystone_url -s http://192.168.186.11:5000/v3
cfy secrets create os_region -s RegionOne
```
Parametry należy odczytać z pliku openrc.sh - utworzonego w poprzednim ćwiczeniu, natomiast nazwę regionu należy odczytać z użyciem CLI openstack skonfigurowanego w pierwszym ćwiczeniu

### KROK 2: Urchomienie Serwera Apache Tomcat

- Zerknij w zawartość Bluprintu blueprint.yaml i przygotuj plik z wartościami wejsciowymi dla niego. Jego wzorzec znajdziesz w repozytorium pod nazwą values.yaml. Zauważ, że jako wymagane są tylko wartości, które w Blueprincie nie mają zdefiniowanych wartości domyślnych. Identyfikator odmiany maszyny oraz identyfikator obrazu Ubuntu 14.04 odczytaj za pomocą CLI openstack.

```
 cfy blueprint upload -b openstack ./blueprint.yaml
 cfy deployments create -b openstack openstack-dep --inputs values.yaml
 
```
Wejdź to dashboard Cloudify oraz przejrzyj zawartość utworzonego deploymentu. Zauważ sekcje z wartościami wejściowymi oraz wartościami wyjściowymi. Prześledź zależności pomiędzy tworzonymi obiektami w blueprincie oraz porównaj jego strukturę ze strukturą wzorca HEAT dla OpenStack wykorzystanego uprzednio do instalacji Cloudify Managera.

- Uruchom workflow isnstalacyjny dla uprzednio utworzonego deploymentu

```
cfy executions start -d openstack-dep install
```

Będac w dashboard ze szczegółami utworzonego deploymentu naciśnij wiersz z poleceniem "Install" - uruchomi to podgląd i zarazem wizualizację procesy instalacji maszyny w OpenStack razem z zależnościami.

- Aby uzyskać bezpośredni dostęp do utworzonej maszyny wirtualnej musisz przegrać klucz prywatny utworzony rzez Cloudify 
```
sudo cp /etc/cloudify/.ssh/id_rsa /home/centos/key.pem 
sudo chown centos:centos /home/centos/key.pem 
chmod 400 /home/centos/key.pem 
```
- Dostep do maszyny można uzyskać wykonując następujące polecenie
```
ssh -i /home/centos/key.pem  ubuntu@{vm_external_ip}
```

- Odczytaj zewnętrzny adres IP serwera HTTP i za pomocą przeglądarki zweryfikuj, że masz do niego dostęp

### KROK 3: Weryfikacja działania serwera za pomocą zewnętrznego klienta HTTP
- Utwórz nowy blueprint o nazwie blueprint-ext.yaml, który będzie rozwinięciem tego używanego w kroku 2. 
- Zmodyfikuj grupę zabezpieczeń tak, by dostep do portu 80 możliwy był tylko z sieci prywatnej oraz by nie był możliwy dostęp z zewnątrz np. z poziomu przeglądarki internetowej
- Utwórz razem z serwerem HTTP dodatkową maszynę wirtualną, której celem będzie weryfikacja dostępu do serwera HTTP. Do samej weryfikacji połączenia wykorzystaj skrypt connection.sh, który powinien być wywoływany w momencie tworzenia zależności/interfejsu między serwerem HTTP, a klientem HTTP. 
- Po wykonaniu instalacji odczytaj zewnętrzny adres IP serwera HTTP i za pomocą przeglądarki zweryfikuj, że nie masz teraz do niego dostępu
