# ĆWICZENIE: Wykorzystanie przez Cloudify platformy OpenStack w roli VIM

Pierwsze dwa ćwiczenia nie wymagały współpracy Cloudify z OpenStack, ponieważ nie tworzyliśmy instancji działających usług (utworzenie maszyny managera Cloudify skryptem Openstack/Heat nie wchodzi w zakres takiej współpracy). W niniejszym ćwiczeniu wykorzystamy OpenStack w roli VIM (Virtual Infrastructure Manager wg NFV) do wdrożenia prostej usługi chmurowej.

Celem ćwiczenia jest skonfigurowane Cloudify do współpracy z OpenStack, a następnie uruchomienie i przygotowanie Blueprintu, który zainstaluje serwer Apache Tomcat na maszynie wirtualnej, a następnie przetestuje jego działanie z poziomu drugiej maszyny wirtualnej z prostym klientem HTTP.

W ramach ćwiczenia ilustrujemy w jaki sposób Cloudify wykorzystuje OpenStack w roli VIM na potrzeby:
- tworzenia grup zabezpieczeń
- tworzenia sieci
- tworzenia routerów
- tworzenia maszyn wirtualnych
- uruchamiania skryptów konfiguracyjnych na maszynach wirtualnych.

Wybrane przydatne linki w tym ćwiczeniu:
- blueprints https://docs.cloudify.co/4.6/developer/blueprints/
    * DSL definitions https://docs.cloudify.co/4.2.0/blueprints/spec-dsl-definitions/
- funkcje wewnętrzne (intrinsic functions) Cloudify https://docs.cloudify.co/4.6/developer/blueprints/spec-intrinsic-functions/
- OpenStack CLI https://docs.openstack.org/python-openstackclient/ocata/command-list.html

UWAGA: w ramach ćwiczenia należy wykonać szereg zaplanowanych kroków. Oczywiście jest możliwe poszerzenie zakresu eksperymentów we własnym zakresie, a nietrywialne i udokumentowane w sprawozdaniu próby będą honorowane bonusowymi punktami w wysokości do 20% maksymalnej nominalnej oceny za całe ćwiczenie.

# Przebieg ćwiczenia

### KROK 1: Konfiguracja OpenStack w Cloudify

Przed przystąpieniem do realizacji głównej części ćwiczenia należy skonfigurować dostęp Cloudify do OpenStack podając parametry dostępu do OpenStack pozyskane w pierwszym ćwiczeniu. W tym celu, z użyciem polecenia cfy, należy ustawić tzw. secret values w Cloudify, które będą przechowywać parametry uwierzytelnienia Cloudify w OpenStack:

ogólna forma:
```
cfy secrets list
cfy secrets create os_username -s <username>
cfy secrets create os_password -s <password>
cfy secrets create os_tenant_name -s <project name>
cfy secrets create os_keystone_url -s <url>
cfy secrets create os_region -s <region name>

cfy secrets list
cfy secrets get os_keystone_url
```
przykład:
```
cfy secrets create os_username -s mojlogin
cfy secrets create os_password -s mojehaslo
cfy secrets create os_tenant_name -s cloudify-test
cfy secrets create os_keystone_url -s http://192.168.186.11:5000/v3
cfy secrets create os_region -s RegionOne
```

Parametry do powyższych sekretów należy odczytać z pliku openrc.sh utworzonego w ćwiczeniu 1, natomiast nazwę regionu należy odczytać z użyciem CLI openstack skonfigurowanego w pierwszym ćwiczeniu (w dokumentacji CLI OpenStack znajdź sposób odczytania listy regionów; otwarcie terminala z linią poleceń openstack opisamo w ćwiczeniu 1).

UWAGA: sekrety w Cloudify to wygodny mechanizm zapamiętywania parametrów, do których następnie będzie można się odwoływać w różnych konstrukcjach Cloudify, np. w linii poleceń cfy czy blueprintach.

### KROK 2: Urchomienie Serwera Apache Tomcat

- Zerknij w zawartość Bluprintu blueprint.yaml i przygotuj plik z wartościami wejściowymi dla niego. Jego wzorzec znajdziesz w repozytorium pod nazwą values.yaml. Zauważ, że jako wymagane są tylko wartości, które w Blueprincie nie mają zdefiniowanych wartości domyślnych. Identyfikator odmiany maszyny oraz identyfikator obrazu Ubuntu 14.04 odczytaj za pomocą CLI openstack.

```
 cfy blueprint upload -b openstack ./blueprint.yaml
 cfy deployments create -b openstack openstack-dep --inputs values.yaml
 
```
Wejdź to dashboard Cloudify oraz przejrzyj zawartość utworzonego deploymentu. Zauważ sekcje z wartościami wejściowymi oraz wartościami wyjściowymi. Prześledź zależności pomiędzy tworzonymi obiektami w blueprincie oraz porównaj jego strukturę ze strukturą wzorca HEAT dla OpenStack wykorzystanego w ćwiczeniu 1 do instalacji Cloudify Managera; skomentuj podobieństwa między nimi.

- Uruchom workflow instalacyjny dla uprzednio utworzonego deploymentu:

```
cfy executions start -d openstack-dep install
```

Będąc w oknie dashboard pokazującym szczegóły utworzonego deploymentu naciśnij wiersz z poleceniem "Install" - uruchomi to podgląd i zarazem wizualizację procesu instalacji maszyny w OpenStack razem z zależnościami.

- Aby uzyskać bezpośredni dostęp do utworzonej maszyny wirtualnej musisz wgrać do niej klucz prywatny utworzony przez Cloudify.
```
sudo cp /etc/cloudify/.ssh/id_rsa /home/centos/key.pem 
sudo chown centos:centos /home/centos/key.pem 
chmod 400 /home/centos/key.pem 
```
- Dostęp do maszyny można uzyskać wykonując następujące polecenie:
```
ssh -i /home/centos/key.pem ubuntu@{vm_external_ip}
```

- Odczytaj zewnętrzny adres IP serwera HTTP i za pomocą przeglądarki zweryfikuj, że masz do niego dostęp.

### KROK 3: Weryfikacja działania serwera za pomocą zewnętrznego klienta HTTP

- Utwórz nowy blueprint o nazwie np. blueprint-ext.yaml, który będzie rozwinięciem tego używanego w kroku 2. 
- Zmodyfikuj grupę zabezpieczeń tak, aby dostęp do portu 80 możliwy był tylko z sieci prywatnej oraz nie był możliwy z zewnątrz, np. z poziomu przeglądarki internetowej.
- Utwórz razem z serwerem HTTP dodatkową maszynę wirtualną, której celem będzie weryfikacja dostępu do serwera HTTP. Do samej weryfikacji połączenia wykorzystaj skrypt connection.sh, który powinien być wywoływany w momencie tworzenia zależności / interfejsu między serwerem HTTP a klientem HTTP. 
- Po wykonaniu instalacji odczytaj zewnętrzny adres IP serwera HTTP i za pomocą przeglądarki zweryfikuj, że nie masz teraz do niego dostępu.

# Sprawozdanie z ćwiczenia

Udokumentuj poszczególne kroki ćwiczenia zachowując odpowiednią numerację rozdziałów. W odrębnym punkcie podsumuj całe ćwiczenie. 
