CREATE TABLE IF NOT EXISTS `characters`(
    `charId`                  INT UNSIGNED       NOT NULL DEFAULT 0,
    `account_name`            VARCHAR(45)                 DEFAULT NULL,
    `char_name`               VARCHAR(35)        NOT NULL,
    `level`                   TINYINT UNSIGNED            DEFAULT NULL,
    `maxHp`                   MEDIUMINT UNSIGNED          DEFAULT NULL,
    `curHp`                   MEDIUMINT UNSIGNED          DEFAULT NULL,
    `maxCp`                   MEDIUMINT UNSIGNED          DEFAULT NULL,
    `curCp`                   MEDIUMINT UNSIGNED          DEFAULT NULL,
    `maxMp`                   MEDIUMINT UNSIGNED          DEFAULT NULL,
    `curMp`                   MEDIUMINT UNSIGNED          DEFAULT NULL,
    `face`                    TINYINT UNSIGNED            DEFAULT NULL,
    `hairStyle`               TINYINT UNSIGNED            DEFAULT NULL,
    `hairColor`               TINYINT UNSIGNED            DEFAULT NULL,
    `sex`                     TINYINT UNSIGNED            DEFAULT NULL,
    `heading`                 MEDIUMINT                   DEFAULT NULL,
    `x`                       MEDIUMINT                   DEFAULT NULL,
    `y`                       MEDIUMINT                   DEFAULT NULL,
    `z`                       MEDIUMINT                   DEFAULT NULL,
    `exp`                     BIGINT UNSIGNED             DEFAULT 0,
    `expBeforeDeath`          BIGINT UNSIGNED             DEFAULT 0,
    `sp`                      BIGINT UNSIGNED    NOT NULL DEFAULT 0,
    `reputation`              INT                         DEFAULT NULL,
    `fame`                    MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
    `raidbossPoints`          MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
    `pvpkills`                SMALLINT UNSIGNED           DEFAULT NULL,
    `pkkills`                 SMALLINT UNSIGNED           DEFAULT NULL,
    `clanid`                  INT UNSIGNED                DEFAULT NULL,
    `race`                    TINYINT UNSIGNED            DEFAULT NULL,
    `classid`                 TINYINT UNSIGNED            DEFAULT NULL,
    `base_class`              TINYINT UNSIGNED   NOT NULL DEFAULT 0,
    `transform_id`            SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
    `deletetime`              BIGINT UNSIGNED    NOT NULL DEFAULT '0',
    `cancraft`                TINYINT UNSIGNED            DEFAULT NULL,
    `title`                   VARCHAR(21)                 DEFAULT NULL,
    `title_color`             MEDIUMINT UNSIGNED NOT NULL DEFAULT 0xECF9A2,
    `accesslevel`             MEDIUMINT                   DEFAULT 0,
    `online`                  TINYINT UNSIGNED            DEFAULT NULL,
    `onlinetime`              INT                         DEFAULT NULL,
    `char_slot`               TINYINT UNSIGNED            DEFAULT NULL,
    `lastAccess`              BIGINT UNSIGNED    NOT NULL DEFAULT '0',
    `clan_privs`              INT UNSIGNED                DEFAULT 0,
    `wantspeace`              TINYINT UNSIGNED            DEFAULT 0,
    `power_grade`             TINYINT UNSIGNED            DEFAULT NULL,
    `nobless`                 TINYINT UNSIGNED   NOT NULL DEFAULT 0,
    `subpledge`               SMALLINT           NOT NULL DEFAULT 0,
    `lvl_joined_academy`      TINYINT UNSIGNED   NOT NULL DEFAULT 0,
    `apprentice`              INT UNSIGNED       NOT NULL DEFAULT 0,
    `sponsor`                 INT UNSIGNED       NOT NULL DEFAULT 0,
    `clan_join_expiry_time`   BIGINT UNSIGNED    NOT NULL DEFAULT '0',
    `clan_create_expiry_time` BIGINT UNSIGNED    NOT NULL DEFAULT '0',
    `bookmarkslot`            SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
    `vitality_points`         MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
    `createDate`              DATE               NOT NULL DEFAULT (CURRENT_DATE),
    `language`                VARCHAR(2)                  DEFAULT NULL,
    `pccafe_points`           INT                NOT NULL DEFAULT '0',
    PRIMARY KEY (`charId`),
    KEY `account_name` (`account_name`),
    KEY `char_name` (`char_name`),
    KEY `clanid` (`clanid`),
    KEY `online` (`online`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;


CREATE TABLE IF NOT EXISTS `rankers_snapshot`
(
    `id` INT UNSIGNED      NOT NULL DEFAULT 0,
    `name` VARCHAR(35)       NOT NULL,
    `exp`       BIGINT UNSIGNED           DEFAULT 0,
    `level`     TINYINT UNSIGNED            DEFAULT NULL,
    `class`     TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    `race`      TINYINT UNSIGNED          DEFAULT NULL,
    `clan_name` VARCHAR(45)               DEFAULT '',
    `rank`      BIGINT UNSIGNED           DEFAULT 0,
    `rank_race` BIGINT UNSIGNED           DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8MB4;


CREATE TABLE IF NOT EXISTS `rankers_race_snapshot`
(
    `id`    INT UNSIGNED     NOT NULL DEFAULT 0,
    `name`  VARCHAR(35)      NOT NULL,
    `exp`       BIGINT UNSIGNED           DEFAULT 0,
    `level`     TINYINT UNSIGNED            DEFAULT NULL,
    `class`     TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `race`      TINYINT UNSIGNED          DEFAULT NULL,
    `clan_name` VARCHAR(45)              DEFAULT '',
    `rank`      BIGINT UNSIGNED           DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8MB4;

CREATE VIEW rankers_race AS
SELECT charId as id,
       char_name as name,
       exp,
       level,
       base_class as class,
       race,

       IFNULL((SELECT clan_name
                FROM clan_data clan
                WHERE clan.clan_id = clanid), ''
           ) as clan_name,

       rank() over (
           PARTITION BY race
           ORDER BY exp desc
           ) as 'rank'

from characters
where level >= 76
  AND (base_class BETWEEN 88 AND 118 OR base_class IN (131, 134, 195))
LIMIT 150;

CREATE VIEW rankers AS
SELECT c.charId as id,
       c.char_name as name,
       c.exp,
       c.level,
       c.base_class  as class,
       c.race,

       IFNULL((SELECT clan_name
                FROM clan_data clan
                WHERE clan.clan_id = c.clanid), ''
           ) as clan_name,

       rank() over (w)  as `rank`,

       (SELECT `rank`
        FROM rankers_race r
        WHERE r.id = c.charId
             )  as `rank_race`,

        IFNULL(rs.`rank`, 0) as `rank_snapshot`,
        IFNULL(rs.rank_race, 0) as `rank_race_snapshot`

from characters c LEFT JOIN rankers_snapshot rs on c.charId = rs.id
where c.level >= 76
  AND (c.base_class BETWEEN 88 AND 118 OR c.base_class IN (131, 134, 195))
    WINDOW w as (ORDER BY c.exp desc )
LIMIT 150;