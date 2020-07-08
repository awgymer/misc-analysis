from typing import List, Union
import logging
from dataclasses import dataclass
import datetime
import csv

import requests
from bs4 import BeautifulSoup


log = logging.getLogger('Football Wiki Scraper')
ch = logging.StreamHandler()
formatter = logging.Formatter(
    "%(asctime)s | %(name)s | %(levelname)7s | %(message)s",
    "%Y-%m-%d %H:%M:%S"
)
ch.setFormatter(formatter)
log.addHandler(ch)
log.setLevel(logging.INFO)


ASSOCS = {
    'Afghanistan': 'AFG',
    'Albania': 'ALB',
    'Algeria': 'ALG',
    'American Samoa': 'ASA',
    'Andorra': 'AND',
    'Angola': 'ANG',
    'Anguilla': 'AIA',
    'Antigua & Barbuda': 'ATG',
    'Argentina': 'ARG',
    'Armenia': 'ARM',
    'Aruba': 'ARU',
    'Australia': 'AUS',
    'Austria': 'AUT',
    'Azerbaijan': 'AZE',
    'Bahamas': 'BAH',
    'Bahrain': 'BHR',
    'Bangladesh': 'BAN',
    'Barbados': 'BRB',
    'Belarus': 'BLR',
    'Belgium': 'BEL',
    'Belize': 'BLZ',
    'Benin': 'BEN',
    'Bermuda': 'BER',
    'Bhutan': 'BHU',
    'Bolivia': 'BOL',
    'Bosnia & Herzegovina': 'BIH',
    'Botswana': 'BOT',
    'Brazil': 'BRA',
    'British Virgin Islands': 'VGB',
    'Brunei': 'BRU',
    'Bulgaria': 'BUL',
    'Burkina Faso': 'BFA',
    'Burundi': 'BDI',
    'Cape Verde': 'CPV',
    'Cambodia': 'CAM',
    'Cameroon': 'CMR',
    'Canada': 'CAN',
    'Cayman Islands': 'CAY',
    'Central African Republic': 'CTA',
    'Chad': 'CHA',
    'Chile': 'CHI',
    'China': 'CHN',
    'Chinese Taipei': 'TPE',
    'Colombia': 'COL',
    'Comoros': 'COM',
    'Congo': 'CGO',
    'Congo DR': 'COD',
    'Cook Islands': 'COK',
    'Costa Rica': 'CRC',
    'Ivory Coast': 'CIV',
    'Croatia': 'CRO',
    'Cuba': 'CUB',
    'Curaçao': 'CUW',
    'Cyprus': 'CYP',
    'Czech Republic': 'CZE',
    'Denmark': 'DEN',
    'Djibouti': 'DJI',
    'Dominica': 'DMA',
    'Dominican Republic': 'DOM',
    'Ecuador': 'ECU',
    'Egypt': 'EGY',
    'El Salvador': 'SLV',
    'England': 'ENG',
    'Equatorial Guinea': 'EQG',
    'Eritrea': 'ERI',
    'Estonia': 'EST',
    'eSwatini': 'SWZ',
    'Ethiopia': 'ETH',
    'Faroe Islands': 'FRO',
    'Fiji': 'FIJ',
    'Finland': 'FIN',
    'France': 'FRA',
    'Gabon': 'GAB',
    'Gambia': 'GAM',
    'Georgia': 'GEO',
    'Germany': 'GER',
    'Ghana': 'GHA',
    'Gibraltar': 'GIB',
    'Greece': 'GRE',
    'Grenada': 'GRN',
    'Guam': 'GUM',
    'Guatemala': 'GUA',
    'Guinea': 'GUI',
    'Guinea-Bissau': 'GNB',
    'Guyana': 'GUY',
    'Haiti': 'HAI',
    'Honduras': 'HON',
    'Hong Kong': 'HKG',
    'Hungary': 'HUN',
    'Iceland': 'ISL',
    'India': 'IND',
    'Indonesia': 'IDN',
    'Iran': 'IRN',
    'Iraq': 'IRQ',
    'Israel': 'ISR',
    'Italy': 'ITA',
    'Jamaica': 'JAM',
    'Japan': 'JPN',
    'Jordan': 'JOR',
    'Kazakhstan': 'KAZ',
    'Kenya': 'KEN',
    'North Korea': 'PRK',
    'South Korea': 'KOR',
    'Kosovo': 'KVX',
    'Kuwait': 'KUW',
    'Kyrgyzstan': 'KGZ',
    'Laos': 'LAO',
    'Latvia': 'LVA',
    'Lebanon': 'LBN',
    'Lesotho': 'LES',
    'Liberia': 'LBR',
    'Libya': 'LBY',
    'Liechtenstein': 'LIE',
    'Lithuania': 'LTU',
    'Luxembourg': 'LUX',
    'Macau': 'MAC',
    'Madagascar': 'MAD',
    'Malawi': 'MWI',
    'Malaysia': 'MAS',
    'Maldives': 'MDV',
    'Mali': 'MLI',
    'Malta': 'MLT',
    'Mauritania': 'MTN',
    'Mauritius': 'MRI',
    'Mexico': 'MEX',
    'Moldova': 'MDA',
    'Mongolia': 'MNG',
    'Montenegro': 'MNE',
    'Montserrat': 'MSR',
    'Morocco': 'MAR',
    'Mozambique': 'MOZ',
    'Myanmar': 'MYA',
    'Namibia': 'NAM',
    'Nepal': 'NEP',
    'Netherlands': 'NED',
    'New Caledonia': 'NCL',
    'New Zealand': 'NZL',
    'Nicaragua': 'NCA',
    'Niger': 'NIG',
    'Nigeria': 'NGA',
    'North Macedonia': 'MKD',
    'Northern Ireland': 'NIR',
    'Norway': 'NOR',
    'Oman': 'OMA',
    'Pakistan': 'PAK',
    'Palestine': 'PLE',
    'Panama': 'PAN',
    'Papua New Guinea': 'PNG',
    'Paraguay': 'PAR',
    'Peru': 'PER',
    'Philippines': 'PHI',
    'Poland': 'POL',
    'Portugal': 'POR',
    'Puerto Rico': 'PUR',
    'Qatar': 'QAT',
    'Republic of Ireland': 'IRL',
    'Romania': 'ROU',
    'Russia': 'RUS',
    'Rwanda': 'RWA',
    'Samoa': 'SAM',
    'San Marino': 'SMR',
    'São Tomé & Príncipe': 'STP',
    'Saudi Arabia': 'KSA',
    'Scotland': 'SCO',
    'Senegal': 'SEN',
    'Serbia': 'SRB',
    'Seychelles': 'SEY',
    'Sierra Leone': 'SLE',
    'Singapore': 'SIN',
    'Slovakia': 'SVK',
    'Slovenia': 'SVN',
    'Solomon Islands': 'SOL',
    'Somalia': 'SOM',
    'South Africa': 'RSA',
    'South Sudan': 'SSD',
    'Spain': 'ESP',
    'Sri Lanka': 'SRI',
    'Saint Kitts & Nevis': 'SKN',
    'Saint Lucia': 'LCA',
    'Saint Vincent & the Grenadines': 'VIN',
    'Sudan': 'SDN',
    'Suriname': 'SUR',
    'Sweden': 'SWE',
    'Switzerland': 'SUI',
    'Syria': 'SYR',
    'Tahiti': 'TAH',
    'Tajikistan': 'TJK',
    'Tanzania': 'TAN',
    'Thailand': 'THA',
    'Timor-Leste': 'TLS',
    'Togo': 'TOG',
    'Tonga': 'TGA',
    'Trinidad & Tobago': 'TRI',
    'Tunisia': 'TUN',
    'Turkey': 'TUR',
    'Turkmenistan': 'TKM',
    'Turks & Caicos Islands': 'TCA',
    'Uganda': 'UGA',
    'Ukraine': 'UKR',
    'United Arab Emirates': 'UAE',
    'Uruguay': 'URU',
    'US Virgin Islands': 'VIR',
    'USA': 'USA',
    'Uzbekistan': 'UZB',
    'Vanuatu': 'VAN',
    'Venezuela': 'VEN',
    'Vietnam': 'VIE',
    'Wales': 'WAL',
    'Yemen': 'YEM',
    'Zambia': 'ZAM',
    'Zimbabwe': 'ZIM',
}

ASSOC_MAP = {
    "Ireland (Northern Ireland)": "Northern Ireland",
    "Bohemia (Czech Republic)": "Czech Republic",
    "United States": "USA",
    "China PR": "China",
    "Soviet Union": "USSR",
    "Palestine, British Mandate": None,
    "South Vietnam": "Vietnam",
    "Saarland": None,
    "East Germany": None,
    "North Vietnam": "Vietnam",
    "South Yemen": "Yemen",
    "(North) Yemen": "Yemen",
    "Swaziland": "eSwatini",
    "Macedonia": "North Macedonia",
    "U.S. Virgin Islands": "US Virgin Islands"
}


TEAM_MAP = {
    'Ireland (1882–1950)': "Northern Ireland",
    'Czechoslovakia': "Czech Republic",
    'Russian Empire': "Russia",
    'China PR': "China",
    'Malaya': "Malaysia",
    'Belgian Congo': "Congo DR",
    'Yemen': "Yemen",
    'South Yemen': "Yemen",
    'Saint Christopher-Nevis-Anguilla': "Saint Kitts & Nevis",
    'Macedonia': "Macedonia",
    'United States Virgin Islands': "US Virgin Islands",
    'United States': 'USA',
    'Swaziland': 'eSwatini',
    'North Vietnam': 'Vietnam',
    'South Vietnam': 'Vietnam',
    'Soviet Union': 'USSR',
}


@dataclass
class Match():
    datestr: str
    ko_year: int
    match_type: str
    team_0: str
    team_1: str
    score_0: int
    score_1: int
    venue: str
    deb_for: List[str]

    @property
    def teams(self):
        return [self.team_0, self.team_1]


def parse_date(text):
    for fmt in ('%d %B %Y', '%B %Y', '%Y'):
        try:
            return datetime.datetime.strptime(text, fmt)
        except ValueError:
            pass
    raise ValueError(f'No valid date format found for {text}')


def ands_to_ampersand(text):
    and_teams = (
        ('Trinidad and Tobago', 'Trinidad & Tobago'),
        ('Antigua and Barbuda', 'Antigua & Barbuda'),
        ('São Tomé and Príncipe', 'São Tomé & Príncipe'),
        ('Saint Vincent and the Grenadines', 'Saint Vincent & the Grenadines'),
        ('Wallis and Futuna', 'Wallis & Futuna'),
        ('Bosnia and Herzegovina', 'Bosnia & Herzegovina'),
        ('Turks and Caicos Islands', 'Turks & Caicos Islands'),
    )
    for a in and_teams:
        text = text.replace(a[0], a[1])
    return text


def clean_team(text):
    for r in [" men's national soccer team", ' national football team', ' national soccer team']:
        text = text.replace(r, '')
    return TEAM_MAP.get(text, text)


def extract_team(td):
    links = td.find_all('a')
    if len(links) > 1:
        for i, l in enumerate(links):
            print(f'[{i}] {l.text}')
        link_idx = input('Enter the correct link index: ')
        link_idx = int(link_idx)
        return links[link_idx]
    return links[0]


def scrape_matches(url, htype='h2'):
    r = requests.get(url)
    soup = BeautifulSoup(r.text, features="html.parser")
    content = soup.find(id='bodyContent')
    heads = content.find(class_='mw-parser-output').find_all(htype)
    matches = []
    for h in heads:
        hcontent = h.find(class_='mw-headline').text
        hcontent = ands_to_ampersand(hcontent)
        if hcontent in ('See also', 'Notes', 'References', 'External links'):
            continue
        log.info('Processing: %s', hcontent)
        inforow = h.find_next('table').find('tr')
        for s in inforow('sup'):
            s.extract()
        dat, t1, score, t2, loc = inforow.find_all('td')
        dt = dat.span.text.strip()
        ko_year = parse_date(dt).year
        match_type = dat.small.text
        team_0 = ands_to_ampersand(extract_team(t1).attrs['title'])
        team_1 = ands_to_ampersand(extract_team(t2).attrs['title'])
        team_0 = clean_team(team_0)
        team_1 = clean_team(team_1)
        # This is not a regular hyphen! Had to be copied from wiki!
        score_0, score_1 = [int(s.strip()) for s in score.text.split('–')]
        venue = loc.text
        debs = hcontent.split(' and ')
        debs = [ASSOC_MAP.get(d, d) for d in debs]
        matches.append(
            Match(
                dt, ko_year, match_type,
                team_0, team_1,
                score_0, score_1,
                venue, debs
            )
        )
    return matches


def main():
    wikiurls = [
        ('https://en.wikipedia.org/wiki/List_of_first_association_football_internationals_per_country:_before_1940', 'h2'),
        ('https://en.wikipedia.org/wiki/List_of_first_association_football_internationals_per_country:_1940%E2%80%931962', 'h2'),
        ('https://en.wikipedia.org/wiki/List_of_first_association_football_internationals_per_country:_since_1962', 'h3')
    ]

    all_match = []
    for url, htype in wikiurls:
        all_match.extend(scrape_matches(url, htype))

    all_debs = []
    for m in all_match:
        all_debs.extend(m.deb_for)

    print('Checking match details')
    for i, m in enumerate(all_match):
        for t in m.deb_for:
            if t not in m.teams:
                print(f'[{i}] Association {t} not in {m.teams}')
            if t not in ASSOCS:
                print(f'Association {t} is not a current FIFA member!')

    for a in ASSOCS:
        if a not in all_debs:
            print(a)

    recs = []
    for m in all_match:
        for t in m.deb_for:
            if t is None:
                print('Skipping "None" team')
                continue
            if t == 'Czechoslovakia':
                idx = m.teams.index('Czech Republic')
                setattr(m, f'team_{idx}', 'Czechoslovakia')
            else:
                idx = m.teams.index(t)
            if idx == 0:
                opp_idx = 1
            else:
                opp_idx = 0
            tm_score = getattr(m, f'score_{idx}')
            opp_score = getattr(m, f'score_{opp_idx}')
            outcome = 'D'
            if tm_score > opp_score:
                outcome = 'W'
            elif opp_score > tm_score:
                outcome = 'L'
            recs.append({
                'team_name': getattr(m, f'team_{idx}'),
                'oppname': getattr(m, f'team_{opp_idx}'),
                'outcome': outcome,
                'score': f'{tm_score} - {opp_score}',
                'venue': m.venue,
                'ko_year': m.ko_year,
                'ko_date': m.datestr
            })

    with open('first_footbal_match.csv', 'w') as outcsv:
        fieldnames = list(recs[0].keys())
        writer = csv.DictWriter(outcsv, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(recs)
