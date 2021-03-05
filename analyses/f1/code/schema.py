import sqlalchemy
from sqlalchemy import Column
import sqlalchemy.dialects.postgresql as postgresql

from _base import DBBase


class Circuit(DBBase):
    __tablename__ = 'circuits'
    sport_id = Column(
        sqlalchemy.INTEGER,
        primary_key=True,
        autoincrement=False)
    initials = Column(sqlalchemy.TEXT)
    full_name = Column(sqlalchemy.TEXT)
    teams = sqlalchemy.orm.relationship("Team", backref="sport")

    def __repr__(self):
        return f'Sport(id={self.sport_id}, name={self.full_name})'
